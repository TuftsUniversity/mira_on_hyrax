# frozen_string_literal: true
require 'csv'
require 'fileutils'
require 'logger'
require 'set'

module Tufts
  ##
  # Command-line ingest flow for pairing XML metadata with a CSV manifest of
  # public Box URLs.
  class BoxAudioIngestService
    REQUIRED_HEADERS = [:filename].freeze

    attr_reader :xml_path, :manifest_path, :username, :import_id, :batch_size,
                :download_retries, :progress_io

    def self.run!(**kwargs)
      new(**kwargs).run!
    end

    def initialize(xml_path:, manifest_path:, username:, import_id: nil,
                   batch_size: 25, download_retries: 3, progress_io: $stdout)
      @xml_path = xml_path
      @manifest_path = manifest_path
      @username = username
      @import_id = import_id
      @batch_size = [batch_size.to_i, 1].max
      @download_retries = [download_retries.to_i, 0].max
      @progress_io = progress_io
      @summary = Hash.new(0)
      @pending_rows = []
      @pending_uploaded_file_ids = []
    end

    def run!
      ensure_manifest_exists!
      ensure_user!
      load_or_create_import!
      prepare_run_directory!
      validate_manifest_headers!
      seed_known_record_filenames!
      seed_known_uploaded_filenames!

      # Safe on restarts because XmlImport#enqueue! is idempotent for records
      # that already have an object or queued job.
      import.batch.enqueue!

      log("Starting Box ingest for XmlImport ##{import.id}")

      CSV.foreach(manifest_path, headers: true, header_converters: header_converter) do |row|
        process_row(row)
        flush_pending! if pending_uploaded_file_ids.size >= batch_size
      end

      flush_pending!
      log("Completed Box ingest for XmlImport ##{import.id}: #{summary_string}")

      summary.merge(import_id: import.id, run_directory: run_directory.to_s)
    rescue StandardError => err
      cleanup_pending_uploads!
      log("Box ingest failed for XmlImport ##{import&.id || 'new'}: #{err.class}: #{err.message}")
      raise
    end

    private

    attr_reader :import, :known_record_filenames, :known_uploaded_filenames, :summary,
                :pending_rows, :pending_uploaded_file_ids, :progress_logger, :user

    def cleanup_pending_uploads!
      pending_uploaded_file_ids.each do |uploaded_file_id|
        Hyrax::UploadedFile.find(uploaded_file_id).destroy!
      rescue ActiveRecord::RecordNotFound
        next
      end

      pending_rows.each do |row|
        known_uploaded_filenames.delete(row[:filename])
      end

      pending_rows.clear
      pending_uploaded_file_ids.clear
    end

    def create_uploaded_file!(path:)
      File.open(path, 'rb') do |file|
        Hyrax::UploadedFile.create!(user: user, file: file)
      end
    end

    def current_row_status(row)
      record = record_for_filename(row[:filename])
      object_id = import.record_ids[record.file]
      item = import.batch.items.find { |batch_item| batch_item.id == object_id } if object_id.present?

      if item&.job_id.present? || item&.object.present?
        ['queued', object_id, 'File accepted and record enqueued']
      elsif object_id.present?
        ['ready', object_id, 'File accepted; object id assigned']
      else
        ['staged', nil, 'File accepted; waiting for companion files before enqueue']
      end
    end

    def downloads_directory
      run_directory.join('downloads')
    end

    def ensure_manifest_exists!
      raise ArgumentError, "Manifest file not found: #{manifest_path}" unless File.exist?(manifest_path)
    end

    def ensure_safe_filename!(filename)
      return if filename == File.basename(filename)

      raise ArgumentError, "Filenames must not include directory separators: #{filename}"
    end

    def ensure_user!
      @user = User.find_by_user_key(username)
      raise ActiveRecord::RecordNotFound, "User not found for username #{username}" unless user
    end

    def flush_pending!
      return if pending_uploaded_file_ids.empty?

      persisted_rows = pending_rows.dup
      persisted = false

      Tufts::XmlImportSubmissionService.submit!(import: import,
                                                uploaded_file_ids: pending_uploaded_file_ids,
                                                enqueue: false)
      persisted = true

      pending_rows.clear
      pending_uploaded_file_ids.clear
      import.batch.enqueue!

      persisted_rows.each do |row|
        status, object_id, message = current_row_status(row)
        summary[:submitted] += 1
        log_row(status: status,
                filename: row[:filename],
                box_url: row[:box_url],
                uploaded_file_id: row[:uploaded_file_id],
                object_id: object_id,
                message: message)
      end

      log("Progress for XmlImport ##{import.id}: #{summary_string}")
    rescue StandardError => err
      status = persisted ? 'persisted' : 'failed'
      message = if persisted
                  "Uploaded file saved to import but enqueue failed: #{err.class}: #{err.message}"
                else
                  "Failed to save uploaded files to the import: #{err.class}: #{err.message}"
                end

      persisted_rows.each do |row|
        log_row(status: status,
                filename: row[:filename],
                box_url: row[:box_url],
                uploaded_file_id: row[:uploaded_file_id],
                object_id: nil,
                message: message)
      end
      raise
    end

    def header_converter
      lambda do |header|
        header.to_s.strip.downcase.tr(' ', '_').to_sym
      end
    end

    def load_or_create_import!
      @import =
        if import_id.present?
          XmlImport.find(import_id)
        else
          build_import!
        end

      raise "XmlImport ##{import.id} does not have a batch" unless import.batch
    end

    def build_import!
      metadata_file = File.open(xml_path)
      import = XmlImport.new(metadata_file: metadata_file)
      batch = Batch.create!(batchable: import, creator: user, ids: [])
      import.batch = batch
      import.save!
      import
    rescue StandardError
      batch&.destroy
      raise
    ensure
      metadata_file&.close unless metadata_file&.closed?
    end

    def log(message)
      progress_io.puts(message)
      progress_logger&.info(message)
    end

    def log_row(status:, filename:, box_url:, uploaded_file_id:, object_id:, message:)
      CSV.open(results_path, File.exist?(results_path) ? 'ab' : 'wb') do |csv|
        csv << %w[timestamp status filename box_url uploaded_file_id object_id message] unless File.size?(results_path)
        csv << [Time.current.iso8601, status, filename, box_url, uploaded_file_id, object_id, message]
      end
    end

    def manifest_headers
      CSV.open(manifest_path, 'rb', headers: true, header_converters: header_converter, &:readline).headers
    end

    def prepare_run_directory!
      FileUtils.mkdir_p(downloads_directory)
      @progress_logger = Logger.new(run_directory.join('progress.log'))
    end

    def process_row(row)
      filename = row[:filename].to_s.strip
      box_url = row[:box_url].to_s.strip.presence || row[:url].to_s.strip.presence

      summary[:rows] += 1

      if filename.blank? || box_url.blank?
        summary[:failed] += 1
        log_row(status: 'failed',
                filename: filename,
                box_url: box_url,
                uploaded_file_id: nil,
                object_id: nil,
                message: 'Manifest rows require filename and box_url columns')
        return
      end

      ensure_safe_filename!(filename)

      unless known_record_filenames.include?(filename)
        summary[:failed] += 1
        log_row(status: 'failed',
                filename: filename,
                box_url: box_url,
                uploaded_file_id: nil,
                object_id: nil,
                message: 'Filename does not match any record in the XML import')
        return
      end

      if known_uploaded_filenames.include?(filename)
        summary[:skipped] += 1
        log_row(status: 'skipped',
                filename: filename,
                box_url: box_url,
                uploaded_file_id: nil,
                object_id: nil,
                message: 'Filename already exists on this import; skipping')
        return
      end

      staged_path = downloads_directory.join(filename)
      Tufts::RemoteFileDownloadService.download!(url: box_url,
                                                 destination_path: staged_path.to_s,
                                                 retries: download_retries,
                                                 logger: progress_logger)
      uploaded_file = create_uploaded_file!(path: staged_path)

      pending_rows << { filename: filename, box_url: box_url, uploaded_file_id: uploaded_file.id }
      pending_uploaded_file_ids << uploaded_file.id
      known_uploaded_filenames.add(filename)
      summary[:downloaded] += 1
    rescue StandardError => err
      summary[:failed] += 1
      known_uploaded_filenames.delete(filename) if filename.present?
      log_row(status: 'failed',
              filename: filename,
              box_url: box_url,
              uploaded_file_id: nil,
              object_id: nil,
              message: "#{err.class}: #{err.message}")
    ensure
      FileUtils.rm_f(staged_path) if defined?(staged_path) && staged_path.present?
    end

    def results_path
      run_directory.join('results.csv')
    end

    def record_for_filename(filename)
      import.record_for(file: filename)
    end

    def run_directory
      Rails.root.join('tmp', 'box_ingest', "xml_import_#{import.id}")
    end

    def seed_known_record_filenames!
      @known_record_filenames = Set.new(import.records.flat_map(&:files))
    end

    def seed_known_uploaded_filenames!
      @known_uploaded_filenames = Set.new(import.uploaded_files.map { |file| file.file.file.filename })
    end

    def summary_string
      "rows=#{summary[:rows]} downloaded=#{summary[:downloaded]} submitted=#{summary[:submitted]} skipped=#{summary[:skipped]} failed=#{summary[:failed]}"
    end

    def validate_manifest_headers!
      headers = manifest_headers
      missing_headers = REQUIRED_HEADERS - headers
      missing_headers << :box_url if (headers & %i[box_url url]).empty?
      return if missing_headers.empty?

      raise ArgumentError, "Manifest is missing required headers: #{missing_headers.join(', ')}"
    end
  end
end
