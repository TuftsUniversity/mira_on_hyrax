# frozen_string_literal: true

module Tufts
  class BoxAudioSubmissionBuffer
    delegate :empty?, :size, to: :uploaded_file_ids

    attr_reader :import, :summary, :logger, :status_resolver, :progress_notifier

    def initialize(import:, summary:, logger:, status_resolver:, progress_notifier:)
      @import = import
      @summary = summary
      @logger = logger
      @status_resolver = status_resolver
      @progress_notifier = progress_notifier
      @rows = []
      @uploaded_file_ids = []
    end

    def add(entry)
      rows << entry
      uploaded_file_ids << entry[:uploaded_file_id]
    end

    def clear_known_filenames!(known_uploaded_filenames)
      rows.each { |row| known_uploaded_filenames.delete(row[:filename]) }
    end

    def cleanup_uploads!
      uploaded_file_ids.each do |uploaded_file_id|
        Hyrax::UploadedFile.find(uploaded_file_id).destroy!
      rescue ActiveRecord::RecordNotFound
        next
      end
    end

    def flush!
      return if empty?

      persisted_rows = rows.dup
      submit_pending_files!
      log_submitted_rows(persisted_rows)
      progress_notifier.call
    rescue StandardError => err
      log_failed_rows(err, persisted_rows, @persisted)
      raise
    ensure
      clear!
    end

    private

    attr_reader :rows, :uploaded_file_ids

    def clear!
      rows.clear
      uploaded_file_ids.clear
    end

    def log_failed_rows(error, persisted_rows, persisted)
      message =
        if persisted
          "Uploaded file saved to import but enqueue failed: #{error.class}: #{error.message}"
        else
          "Failed to save uploaded files to the import: #{error.class}: #{error.message}"
        end

      persisted_rows.each do |row|
        logger.log_row(row.merge(status: persisted ? 'persisted' : 'failed',
                                 object_id: nil,
                                 message: message))
      end
    end

    def log_submitted_rows(persisted_rows)
      persisted_rows.each do |row|
        status, object_id, message = status_resolver.call(row)
        summary[:submitted] += 1
        logger.log_row(row.merge(status: status, object_id: object_id, message: message))
      end
    end

    def submit_pending_files!
      Tufts::XmlImportSubmissionService.submit!(import: import,
                                                uploaded_file_ids: uploaded_file_ids,
                                                enqueue: false)
      @persisted = true
      import.batch.enqueue!
    end
  end
end
