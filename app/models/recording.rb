class Recording < ActiveRecord::Base
  include Recent
  include Download

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
      self.state = :new
    end
  end
  handle_asynchronously :download!

  def move_files!
    tmp_path = get_tmp_path
    new_path = get_recordings_path
    FileUtils.move tmp_path, new_path

    self.start_release
  end
  handle_asynchronously :move_files!

  def release!
    # webgen
    p self
    self.finish_release
  end
  handle_asynchronously :release!

  private

  def get_tmp_path
    File.join(MediaBackend::Application.config.folders[:tmp_dir], 
              Digest::MD5.hexdigest(self.filename))
  end

  def get_recordings_path
    path = File.join MediaBackend::Application.config.folders[:recordings_base_dir], self.event.conference.recordings_path
    path = File.join path, get_mime_type_path
    FileUtils.mkdir_p path
    File.join path, self.filename
  end

  def get_mime_type_path
    path = MediaBackend::Application.config.mime_type_folder_mappings[self.mime_type]
    path || ""
  end

end
