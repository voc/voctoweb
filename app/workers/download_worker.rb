class DownloadWorker
  include Sidekiq::Worker
  include Downloader

  def perform(conference_path, filename, url)
    FileUtils.mkdir_p conference_path
    path = File.join conference_path, filename
    logger.info "downloading #{url} to #{path}"
    download_to_file(url, path)
  end
end
