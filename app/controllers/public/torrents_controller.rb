class Public::TorrentsController < ApplicationController
  def index
    @torrent_hashes = MirrorFile.torrent_hashes
    respond_to do |format|
      format.text
    end
  end
end
