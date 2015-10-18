class Recording < ActiveRecord::Base
  include Recent
  include Storage
  include AASM

  belongs_to :event
  has_one :conference, through: :event
  has_many :recording_views, dependent: :destroy

  validates_presence_of :event
  validates :folder, length: { minimum: 0, allow_nil: false, message: "can't be nil" }
  validates_presence_of :filename, :mime_type, :length
  validate :unique_recording

  scope :downloaded, -> { where(state: 'downloaded') }
  scope :video, -> { where(mime_type: %w[vnd.voc/mp4-web vnd.voc/webm-web video/mp4 vnd.voc/h264-lq vnd.voc/h264-hd vnd.voc/h264-sd vnd.voc/webm-hd video/ogg video/webm]) }

  scope :recorded_at, ->(conference) { joins(event: :conference).where(events: {'conference_id' => conference} ) }

  after_save :update_downloaded_count
  after_save { event.touch }

  has_attached_file :recording, via: :filename, folder: :folder, belongs_into: :recordings, on: :conference

  aasm column: :state do
    state :new, initial: true
    state :downloading
    state :downloaded

    event :download_failed do
      transitions to: :new
    end

    event :start_download, after: :download! do
      transitions to: :downloading
    end

    event :finish_download, after: :move_files! do
      transitions from: :downloading, to: :downloaded
    end
  end

  def download!
    VideoDownloadWorker.perform_async(self.id)
  end

  def move_files!
    VideoMoveWorker.perform_async(self.id)
  end

  def display_name
    if self.event.present?
      str = self.event.display_name
    else
     str = self.filename
    end

    return self.id if str.empty?
    str
  end

  def validate_for_api
    self.errors.add(:folder, "recording folder #{self.conference.get_recordings_path} not writable") unless File.writable? self.conference.get_recordings_path
    self.errors.add(:original_url, 'missing original_url') if self.original_url.nil?
    not self.errors.any?
  end

  def unique_recording
    unless self.event.present?
      self.errors.add :event, 'missing event on recording'
      return
    end
    dupe = self.event.recordings.select { |recording|
      recording.filename == self.filename && recording.folder == self.folder
    }.delete_if { |dupe| dupe == self }
    self.errors.add :event, 'recording already exist on event' if dupe.present?
  end

  private

  def update_downloaded_count
    return true unless downloaded?
    conference.update_column :downloaded_events_count, Event.recorded_at(conference).to_a.size
  end
end
