# frozen_string_literal: true
require 'open-uri'
require 'net/http'

module Downloader
  # Download url without using a buffer.
  #
  # @param url [String] source url
  # return [String] content of the url
  def download(url)
    content = ''
    uri = URI(url)
    if uri.scheme.nil? || uri.scheme == 'file'
      path = absolute_path(uri)
      File.open(path, 'r:UTF-8') { |f| content = f.read }
    else
      content = URI.parse(url).open.read
    end
    return content.to_s
  end

  # Buffered download of URL to path, moves file if url scheme is file.
  #
  # @param url [String] source url
  # @param path [String] target path
  # return [Boolean] if the operation was successful
  def download_to_file(url, path)
    result = false

    uri = URI(url)
    if uri.scheme == 'file'
      result = FileUtils.mv uri.path, path
      Rails.logger.info "Moved to #{path}" if result == 0
    else
      result = download_url_to_file uri, path
    end
    result
  end

  private

  # URI does not distinguish between file:// and file:///, so fallback to readable?
  def absolute_path(uri)
    return uri.path if File.readable?(uri.path)
    File.join(Rails.root, uri.path)
  end

  def download_url_to_file(uri, path)
    result = nil

    File.open(path, 'wb') do |f|
      result = download_io(f, uri)
    end
    unless result
      File.unlink path
    end
    Rails.logger.info "Downloaded to #{path}" if result
    result
    #rescue
    #  Rails.logger.error "Failed download of #{uri} to #{path}: #{$!}"
    #  return
  end

  # Buffered HTTP download
  def download_io(fileio, uri)
    request = Net::HTTP::Get.new uri

    result = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|

      http.request request do |response|
        response.read_body do |buffer|
          fileio.write buffer
        end
      end

    end

    result.is_a? Net::HTTPSuccess
  end
end
