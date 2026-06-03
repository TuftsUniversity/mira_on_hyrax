# frozen_string_literal: true
module Tufts
  ##
  # Command-line ingest flow for pairing XML metadata with a CSV manifest of
  # public Box URLs.
  class BoxAudioIngestService
    include BoxAudioIngestSetup
    include BoxAudioIngestProcessing

    REQUIRED_HEADERS = [:filename].freeze

    attr_reader :xml_path, :manifest_path, :username, :import_id,
                :batch_size, :download_retries

    def self.run!(**kwargs)
      new(**kwargs).run!
    end

    def initialize(xml_path:, manifest_path:, username:, **options)
      @xml_path = xml_path
      @manifest_path = manifest_path
      @username = username
      @import_id = options[:import_id]
      @batch_size = [options.fetch(:batch_size, 25).to_i, 1].max
      @download_retries = [options.fetch(:download_retries, 3).to_i, 0].max
      @progress_io = options.fetch(:progress_io, $stdout)
      @summary = Hash.new(0)
    end

    def run!
      setup_run!
      process_manifest!
      finalize_run!
    rescue StandardError => err
      cleanup_pending_uploads!
      if run_logger
        run_logger.log("Box ingest failed for XmlImport ##{import&.id || 'new'}: #{err.class}: #{err.message}")
      else
        progress_io.puts("Box ingest failed for XmlImport ##{import&.id || 'new'}: #{err.class}: #{err.message}")
      end
      raise
    end
  end
end
