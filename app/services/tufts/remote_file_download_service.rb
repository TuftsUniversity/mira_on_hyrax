# frozen_string_literal: true
require 'fileutils'
module Tufts
  ##
  # Streams a public remote file to disk without loading the full payload into
  # memory. Public Box links are normalized to request a direct download.
  class RemoteFileDownloadService
    include RemoteFileDownloadSupport

    DEFAULT_REDIRECT_LIMIT = 5
    DEFAULT_OPEN_TIMEOUT = 30
    DEFAULT_READ_TIMEOUT = 3600
    DownloadError = Class.new(StandardError)

    RETRIABLE_ERRORS = [
      DownloadError,
      EOFError,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::ETIMEDOUT,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Timeout::Error
    ].freeze

    attr_reader :url, :destination_path, :retries, :logger

    def self.download!(url:, destination_path:, retries: 3, logger: Rails.logger)
      new(url: url,
          destination_path: destination_path,
          retries: retries,
          logger: logger).download!
    end

    def initialize(url:, destination_path:, retries: 3, logger: Rails.logger)
      @url = url
      @destination_path = destination_path
      @retries = retries.to_i
      @logger = logger
    end

    def download!
      with_retries do
        prepare_destination!
        stream_response(uri: normalized_uri(url))
        destination_path
      end
    end

    def cleanup_partial_download!
      FileUtils.rm_f(partial_download_path)
      FileUtils.rm_f(destination_path)
    end

    def normalized_uri(raw_url)
      uri = URI.parse(raw_url)
      raise ArgumentError, "Unsupported URL scheme for #{raw_url}" unless %w[http https].include?(uri.scheme)

      return uri unless uri.host&.match?(/box\.com\z/)

      params = Rack::Utils.parse_nested_query(uri.query)
      params['download'] ||= '1'
      uri.query = params.to_query
      uri
    end

    def prepare_destination!
      FileUtils.mkdir_p(File.dirname(destination_path))
      cleanup_partial_download!
    end

    def partial_download_path
      "#{destination_path}.part"
    end

    def stream_response(uri:, redirect_limit: DEFAULT_REDIRECT_LIMIT)
      raise DownloadError, "Too many redirects for #{url}" if redirect_limit.negative?

      with_http(uri) do |http|
        http.request(build_request(uri)) do |response|
          handle_response(response, uri, redirect_limit)
        end
      end
    end

    def write_response(response)
      File.open(partial_download_path, 'wb') do |file|
        response.read_body do |chunk|
          file.write(chunk)
        end
      end

      FileUtils.mv(partial_download_path, destination_path)
    end
  end
end
