# frozen_string_literal: true
require 'csv'
require 'fileutils'
require 'tempfile'
require 'uri'

module Tufts
  module RemoteUrlIngestSetup
    private

    attr_reader :import, :user, :progress_io, :staged_input_files

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

    def create_uploaded_file!(path:)
      File.open(path, 'rb') do |file|
        Hyrax::UploadedFile.create!(user: user, file: file)
      end
    end

    def manifest_headers
      CSV.open(manifest_path, 'rb', headers: true, header_converters: header_converter, &:readline).headers
    end

    def setup_run!
      resolve_input_sources!
      ensure_manifest_exists!
      ensure_user!
      load_or_create_import!
      build_run_state!
      import.batch.enqueue!
      run_logger.log("Starting remote URL ingest for XmlImport ##{import.id}")
    end

    def cleanup_staged_inputs!
      staged_input_files.each do |file|
        FileUtils.rm_f("#{file.path}.part")
        file.close!
      end
    end

    def finalize_run!
      submission_buffer.flush!
      run_logger.log("Completed remote URL ingest for XmlImport ##{import.id}: #{summary_string}")
      summary.merge(import_id: import.id, run_directory: run_logger.run_directory.to_s)
    end

    def build_run_state!
      @run_logger = Tufts::RemoteUrlRunLogger.new(import: import, progress_io: progress_io)
      run_logger.prepare!
      validate_manifest_headers!
      seed_known_record_filenames!
      seed_known_uploaded_filenames!
      @submission_buffer = Tufts::RemoteUrlSubmissionBuffer.new(
        import: import,
        summary: summary,
        logger: run_logger,
        status_resolver: method(:current_row_status),
        progress_notifier: -> { run_logger.log("Progress for XmlImport ##{import.id}: #{summary_string}") }
      )
    end

    def validate_manifest_headers!
      headers = manifest_headers
      missing_headers = RemoteUrlIngestService::REQUIRED_HEADERS - headers
      missing_headers << :remote_url if (headers & %i[remote_url box_url url]).empty?
      return if missing_headers.empty?

      raise ArgumentError, "Manifest is missing required headers: #{missing_headers.join(', ')}"
    end

    def resolve_input_sources!
      @manifest_path = resolve_input_source!(manifest_source, label: 'manifest')
      @xml_path = resolve_xml_source!
    end

    def resolve_xml_source!
      return nil if import_id.present?

      resolve_input_source!(xml_source, label: 'xml')
    end

    def resolve_input_source!(source, label:)
      raise ArgumentError, "#{label.upcase} is required" if source.blank?
      return source unless remote_source?(source)

      stage_remote_input!(source, label: label)
    end

    def remote_source?(source)
      uri = URI.parse(source)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError, NoMethodError
      false
    end

    def stage_remote_input!(source, label:)
      tempfile = staged_input_file(label, source)
      Tufts::RemoteFileDownloadService.download!(url: source,
                                                 destination_path: tempfile.path,
                                                 retries: download_retries,
                                                 logger: Rails.logger)
      tempfile.path
    rescue StandardError
      FileUtils.rm_f("#{tempfile.path}.part") if defined?(tempfile) && tempfile
      tempfile&.close!
      staged_input_files.delete(tempfile) if defined?(tempfile) && tempfile
      raise
    end

    def staged_input_file(label, source)
      extension = File.extname(URI.parse(source).path)
      extension = '.tmp' if extension.blank?

      Tempfile.new(["remote_url_ingest_#{label}_", extension]).tap do |file|
        file.close
        staged_input_files << file
      end
    end
  end
end
