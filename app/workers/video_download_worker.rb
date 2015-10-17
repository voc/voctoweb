class VideoDownloadWorker
  include Sidekiq::Worker
  include Downloader

  def perform(recording_id)
    recording = Recording.find(recording_id)

    path = get_tmp_path(recording.filename)
    result = download_to_file(recording.original_url, path)
    if result and File.readable? path and File.size(path) > 0
      recording.finish_download!
    else
      recording.download_failed!
    end
  end

  private

  def get_tmp_path(filename)
    File.join(Settings.folders['tmp_dir'],
    Digest::MD5.hexdigest(filename))
  end
end
