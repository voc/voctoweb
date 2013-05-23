require 'active_support/concern'
require 'open-uri'

module Download
  extend ActiveSupport::Concern

  included do
    def download(url)
      # TODO may need to use a buffer and a tmp file if running out of memory?
      open(url).read
    end

    def download_file(f, url)
      http.request_get(url) do |response|
        response.read_body do |buffer|
          f.write(buffer)
        end
      end
    end

  end

end
