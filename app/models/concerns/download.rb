require 'active_support/concern'
require 'open-uri'

module Download
  extend ActiveSupport::Concern

  included do
    def download(url)
      # TODO may need to use a buffer and a tmp file if running out of memory?
      open(url).read
    end
  end

end
