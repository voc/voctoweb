class Recording < ActiveRecord::Base
  include Recent
  include Download

  before_destroy :delete_video

  belongs_to :event

  validates_presence_of :event
  validates_presence_of :filename

  state_machine :state, :initial => :new do

    after_transition any => :downloading do |recording, transition|
      recording.download!
    end

    after_transition any => :downloaded do |recording, transition|
      recording.move_files!
    end

    after_transition any => :releasing do |recording, transition|
      recording.release!
    end

    state :new
    state :downloading
    state :downloaded
    state :releasing
    state :released

    event :download_failed do
      transition all => :new
    end

    event :start_download do
      transition [:new] => :downloading
    end

    event :finish_download do
      transition [:downloading] => :downloaded
    end

    event :start_release do
      transition [:downloaded] => :releasing
    end

    event :finish_release do
      transition [:releasing] => :released
    end

  end

  def download!
    path = get_tmp_path
    result = download_to_file(self.original_url, path)
    if result and File.readable? path and File.size(path) > 0
      self.finish_download
    else
      self.download_failed
    end
  end
  handle_asynchronously :download!

  def move_files!
    tmp_path = get_tmp_path
    create_recording_dir
    FileUtils.move tmp_path, get_recording_path

    self.start_release
  end
  handle_asynchronously :move_files!

  def release!
    # nothing left to do here
    self.finish_release
  end
  handle_asynchronously :release!

  def create_recording_dir
    FileUtils.mkdir_p get_recording_dir
  end

  def get_recording_path
    File.join get_recording_dir, self.filename
  end

  def get_recording_dir
    self.folder ||= ""
    File.join self.event.conference.get_recordings_path, self.folder
  end

  def get_recording_webpath
    self.folder ||= ""
    File.join(self.folder, self.filename)
  end

  private

  def delete_video
    file = get_recording_path
    FileUtils.remove_file file if File.readable? file
  end

  def get_tmp_path
    File.join(MediaBackend::Application.config.folders[:tmp_dir],
    Digest::MD5.hexdigest(self.filename))
  end

end
