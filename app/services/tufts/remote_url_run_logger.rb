# frozen_string_literal: true
require 'csv'
require 'fileutils'
require 'logger'

module Tufts
  class RemoteUrlRunLogger
    attr_reader :import, :progress_io, :progress_logger

    def initialize(import:, progress_io:)
      @import = import
      @progress_io = progress_io
    end

    def prepare!
      FileUtils.mkdir_p(downloads_directory)
      @progress_logger = Logger.new(run_directory.join('progress.log'))
    end

    def log(message)
      progress_io.puts(message)
      progress_logger&.info(message)
    end

    def log_row(entry)
      CSV.open(results_path, File.exist?(results_path) ? 'ab' : 'wb') do |csv|
        csv << %w[timestamp status filename remote_url uploaded_file_id object_id message] unless File.size?(results_path)
        csv << csv_row(entry)
      end
    end

    def downloads_directory
      run_directory.join('downloads')
    end

    def results_path
      run_directory.join('results.csv')
    end

    def run_directory
      Rails.root.join('tmp', 'remote_url_ingest', "xml_import_#{import.id}")
    end

    private

    def csv_row(entry)
      [
        Time.current.iso8601,
        entry[:status],
        entry[:filename],
        entry[:remote_url],
        entry[:uploaded_file_id],
        entry[:object_id],
        entry[:message]
      ]
    end
  end
end
