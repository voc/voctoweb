module Public
  class TorrentsController < ApplicationController
    def index
      @torrent_hashes = Public::MirrorFile.torrent_hashes
      @torrent_hashes.reject! { |torrent| torrent['path'].starts_with? 'INDEX' }
      respond_to do |format|
        format.text
      end
    end
  end
end
