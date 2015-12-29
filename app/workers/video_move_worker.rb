class VideoMoveWorker
  include Sidekiq::Worker
  include Downloader

  sidekiq_options queue: :critical

  def perform(recording_id)
    recording = Recording.find(recording_id)

    tmp_path = get_tmp_path(recording.filename)
    create_recording_dir(recording)
    FileUtils.move tmp_path, recording.get_recording_path
  end

  private

  def create_recording_dir(recording)
    FileUtils.mkdir_p recording.get_recording_dir
  end

  def get_tmp_path(filename)
    File.join(Settings.folders['tmp_dir'],
    Digest::MD5.hexdigest(filename))
  end
end
