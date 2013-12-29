require 'active_support/concern'
require 'open-uri'
require 'net/http'

module Download
  extend ActiveSupport::Concern

  included do
    def download(url)
      # without using a buffer
      open(url).read
    end

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

    def download_url_to_file(uri, path)
      File.open(path, 'wb') do |f|
        result = download_io(f, uri)
      end
      Rails.logger.info "Downloaded to #{path}" if result
      result
    rescue
      Rails.logger.error "Failed download of #{uri} to #{path}: #{$!}"
      return
    end

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

end
