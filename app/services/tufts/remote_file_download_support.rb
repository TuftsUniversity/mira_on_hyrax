# frozen_string_literal: true
require 'net/http'
require 'uri'

module Tufts
  module RemoteFileDownloadSupport
    private

    def with_retries
      attempts = 0

      begin
        attempts += 1
        yield
      rescue *RemoteFileDownloadService::RETRIABLE_ERRORS => err
        cleanup_partial_download!
        raise err if attempts > retries

        logger&.warn("Retrying download for #{url} (attempt #{attempts}/#{retries}) because #{err.class}: #{err.message}")
        retry
      rescue StandardError
        cleanup_partial_download!
        raise
      end
    end

    def with_http(uri)
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https',
                      open_timeout: RemoteFileDownloadService::DEFAULT_OPEN_TIMEOUT,
                      read_timeout: RemoteFileDownloadService::DEFAULT_READ_TIMEOUT) do |http|
        yield http
      end
    end

    def build_request(uri)
      Net::HTTP::Get.new(uri.request_uri).tap do |request|
        request['User-Agent'] = 'mira_remote_url_ingest'
      end
    end

    def handle_response(response, uri, redirect_limit)
      case response
      when Net::HTTPSuccess
        write_response(response)
      when Net::HTTPRedirection
        stream_response(uri: redirect_uri(response, uri), redirect_limit: redirect_limit - 1)
      else
        raise RemoteFileDownloadService::DownloadError, "Failed to download #{url}: #{response.code} #{response.message}"
      end
    end

    def redirect_uri(response, uri)
      location = response['location']
      raise RemoteFileDownloadService::DownloadError, "Redirect response missing location for #{url}" if location.blank?

      URI.join(uri.to_s, location)
    end
  end
end
