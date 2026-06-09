# frozen_string_literal: true
require 'csv'

module Tufts
  module RemoteUrlIngestSetup
    private

    attr_reader :import, :user, :progress_io

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
      ensure_manifest_exists!
      ensure_user!
      load_or_create_import!
      build_run_state!
      import.batch.enqueue!
      run_logger.log("Starting remote URL ingest for XmlImport ##{import.id}")
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
  end
end
