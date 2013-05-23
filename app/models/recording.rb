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
      recording.move_file!
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
    path = File.join(MediaBackend::Application.config.folders.tmp_dir, SecureRandom.hex(16))
    File.open(path, 'wb') do |f|
      download_file(f, self.original_url)
    end
    if not File.readable? file
      self.state = :new
    else
      self.finish_download
    end
  end
  handle_asynchronously :download!

  def move_file!
    # move
    p self
    self.start_release
  end
  handle_asynchronously :move_file!

  def release!
    # webgen
    p self
    self.finish_release
  end
  handle_asynchronously :release!

end
