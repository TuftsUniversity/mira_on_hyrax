# frozen_string_literal: true
module Tufts
  ##
  # Persists uploaded files onto an XmlImport and optionally enqueues ready
  # records for ingest.
  class XmlImportSubmissionService
    Result = Struct.new(:filenames, :added_ids, :existing_ids, :unmatched_ids, keyword_init: true) do
      def added_filenames
        added_ids.map { |id| filenames[id] }
      end

      def existing_filenames
        existing_ids.map { |id| filenames[id] }
      end

      def unmatched_filenames
        unmatched_ids.map { |id| filenames[id] }
      end
    end

    attr_reader :import, :uploaded_file_ids, :enqueue

    def self.submit!(import:, uploaded_file_ids:, enqueue: true)
      new(import: import, uploaded_file_ids: uploaded_file_ids, enqueue: enqueue).submit!
    end

    def initialize(import:, uploaded_file_ids:, enqueue: true)
      @import = import
      @uploaded_file_ids = Array.wrap(uploaded_file_ids).map(&:to_i)
      @enqueue = enqueue
    end

    def submit!
      filenames = filename_hash(uploaded_file_ids)

      import.uploaded_file_ids.concat(uploaded_file_ids)
      import.save!
      import.batch.enqueue! if enqueue

      build_result(filenames: filenames)
    end

    private

    def build_result(filenames:)
      persisted_ids = import.uploaded_file_ids.map(&:to_i)
      added_ids, rejected_ids = filenames.keys.partition do |id|
        persisted_ids.include?(id)
      end
      existing_ids, unmatched_ids = rejected_ids.partition do |id|
        import.record_ids.key?(filenames[id])
      end

      Result.new(filenames: filenames,
                 added_ids: added_ids,
                 existing_ids: existing_ids,
                 unmatched_ids: unmatched_ids)
    end

    def filename_hash(ids)
      Hyrax::UploadedFile.find(ids).each_with_object({}) do |file, hash|
        hash[file.id] = file.file.file.filename
      end
    end
  end
end
