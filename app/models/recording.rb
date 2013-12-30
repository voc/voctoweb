class Recording < ActiveRecord::Base
  include Recent
  include Download
  require 'videopage_builder'

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
    # create yaml in webgen root
    page = VideopageBuilder.save_videopage(self.event.conference, self.event)
    if page.nil?
      Rails.logger.info "Failed to build videopage for #{self.conference.acronym} / #{self.event.guid}"
    else
      self.finish_release
    end
  end
  handle_asynchronously :release!

  def create_recording_dir
    FileUtils.mkdir_p get_recording_dir
  end

  def get_recording_path
    File.join get_recording_dir, self.filename
  end

  def get_recording_dir
    File.join self.event.conference.get_recordings_path, get_mime_type_path
  end

  def get_recording_webpath
    path = get_mime_type_path + '/' + self.filename
    path
  end

  private

  def delete_video
    file = get_recording_path
    FileUtils.remove_file file if File.readable? file

    VideopageBuilder.remove_videopage(self.event.conference, self.event)
    if self.event.recordings.count > 1
      VideopageBuilder.save_videopage(self.event.conference, self.event)
    end
  end

  def get_tmp_path
    File.join(MediaBackend::Application.config.folders[:tmp_dir],
    Digest::MD5.hexdigest(self.filename))
  end

  def get_mime_type_path
    path = MediaBackend::Application.config.mime_type_folder_mappings[self.mime_type]
    path || ""
  end

end
