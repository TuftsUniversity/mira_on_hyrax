# frozen_string_literal: true
module Tufts
  ##
  # Command-line ingest flow for pairing XML metadata with a CSV manifest of
  # public remote URLs. The XML and manifest inputs may be local paths or
  # publicly accessible HTTP(S) URLs.
  class RemoteUrlIngestService
    include RemoteUrlIngestSetup
    include RemoteUrlIngestProcessing

    REQUIRED_HEADERS = [:filename].freeze

    attr_reader :xml_source, :manifest_source, :xml_path, :manifest_path, :username, :import_id,
                :batch_size, :download_retries

    def self.run!(**kwargs)
      new(**kwargs).run!
    end

    def initialize(xml_path:, manifest_path:, username:, **options)
      @xml_source = xml_path
      @manifest_source = manifest_path
      @xml_path = xml_path
      @manifest_path = manifest_path
      @username = username
      @import_id = options[:import_id]
      @batch_size = [options.fetch(:batch_size, 25).to_i, 1].max
      @download_retries = [options.fetch(:download_retries, 3).to_i, 0].max
      @progress_io = options.fetch(:progress_io, $stdout)
      @summary = Hash.new(0)
      @staged_input_files = []
    end

    def run!
      setup_run!
      process_manifest!
      finalize_run!
    rescue StandardError => err
      cleanup_pending_uploads!
      if run_logger
        run_logger.log("Remote URL ingest failed for XmlImport ##{import&.id || 'new'}: #{err.class}: #{err.message}")
      else
        progress_io.puts("Remote URL ingest failed for XmlImport ##{import&.id || 'new'}: #{err.class}: #{err.message}")
      end
      raise
    ensure
      cleanup_staged_inputs!
    end
  end
end
