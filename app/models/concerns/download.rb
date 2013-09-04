require 'active_support/concern'
require 'open-uri'
require 'net/http'

module Download
  extend ActiveSupport::Concern

  included do
    def download(url)
      # TODO may need to use a buffer and a tmp file if running out of memory?
      open(url).read
    end

    def download_to_file(url, path)
      result = false
      File.open(path, 'wb') do |f|
        result = download_io(f, url)
      end
      Rails.logger.info "Downloaded to #{path}"
      result
    end

    private

    def download_io(fileio, url)
      uri = URI(url)

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
