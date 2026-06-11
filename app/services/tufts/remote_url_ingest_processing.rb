# frozen_string_literal: true
require 'csv'
require 'fileutils'
require 'set'

module Tufts
  module RemoteUrlIngestProcessing
    private

    attr_reader :known_record_filenames, :known_uploaded_filenames,
                :summary, :run_logger, :submission_buffer

    def cleanup_pending_uploads!
      return unless submission_buffer

      submission_buffer.cleanup_uploads!
      submission_buffer.clear_known_filenames!(known_uploaded_filenames)
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

    def process_row(row)
      filename = row[:filename].to_s.strip
      remote_url = row[:remote_url].to_s.strip.presence ||
                   row[:box_url].to_s.strip.presence ||
                   row[:url].to_s.strip.presence

      summary[:rows] += 1
      failure = validate_row(filename, remote_url)
      return record_skipped_row(filename, remote_url, failure) if failure

      upload_downloaded_file(filename, remote_url)
    rescue StandardError => err
      record_failed_row(filename, remote_url, "#{err.class}: #{err.message}")
    end

    def process_manifest!
      CSV.foreach(manifest_path, **manifest_csv_options) do |row|
        process_row(row)
        submission_buffer.flush! if submission_buffer.size >= batch_size
      end
    end

    def record_failed_row(filename, remote_url, message)
      summary[:failed] += 1
      known_uploaded_filenames.delete(filename) if filename.present?
      run_logger.log_row(base_log_entry(filename, remote_url).merge(status: 'failed', message: message))
    end

    def record_for_filename(filename)
      import.record_for(file: filename)
    end

    def record_skipped_row(filename, remote_url, result)
      status, message = result
      summary[status.to_sym] += 1
      run_logger.log_row(base_log_entry(filename, remote_url).merge(status: status, message: message))
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

    def upload_downloaded_file(filename, remote_url)
      staged_path = run_logger.downloads_directory.join(filename)
      download_remote_file(remote_url, staged_path)
      uploaded_file = create_uploaded_file!(path: staged_path)
      submission_buffer.add(base_log_entry(filename, remote_url, uploaded_file.id))
      known_uploaded_filenames.add(filename)
      summary[:downloaded] += 1
    ensure
      FileUtils.rm_f(staged_path) if defined?(staged_path) && staged_path.present?
    end

    def download_remote_file(remote_url, staged_path)
      Tufts::RemoteFileDownloadService.download!(url: remote_url,
                                                 destination_path: staged_path.to_s,
                                                 retries: download_retries,
                                                 logger: run_logger.progress_logger)
    end

    def validate_row(filename, remote_url)
      return ['failed', 'Manifest rows require filename and remote_url columns'] if filename.blank? || remote_url.blank?

      ensure_safe_filename!(filename)
      return ['failed', 'Filename does not match any record in the XML import'] unless known_record_filenames.include?(filename)
      return ['skipped', 'Filename already exists on this import; skipping'] if known_uploaded_filenames.include?(filename)
    end

    def base_log_entry(filename, remote_url, uploaded_file_id = nil)
      { filename: filename, remote_url: remote_url, uploaded_file_id: uploaded_file_id, object_id: nil }
    end
  end
end
