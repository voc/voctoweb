class Recording < ActiveRecord::Base
  include Recent
  include Storage
  include AASM

  belongs_to :event
  has_one :conference, through: :event
  has_many :recording_views

  validates_presence_of :event
  validates :folder, length: { minimum: 0, allow_nil: false, message: "can't be nil" }
  validates_presence_of :filename, :mime_type, :length
  validate :unique_recording

  scope :downloaded, -> { where(state: 'downloaded') }
  scope :video, -> { where(mime_type: MimeType::HTML5_VIDEO) }

  after_save { update_conference_downloaded_count if downloaded? }
  after_save { update_event_downloaded_count if downloaded? }
  after_save { update_event_duration if length_changed? }
  after_save { update_event_language if downloaded? && language_changed? }
  after_save { event.touch }
  after_destroy { delete_recording_views }
  after_destroy { update_conference_downloaded_count if downloaded? }
  after_destroy { update_event_downloaded_count if downloaded? }

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
    VideoDownloadWorker.perform_async(id)
  end

  def move_files!
    VideoMoveWorker.perform_async(id)
  end

  def display_name
    if event.present?
      str = event.display_name
    else
      str = filename
    end

    return id if str.empty?
    str
  end

  def validate_for_api
    errors.add(:folder, "recording folder #{conference.get_recordings_path} not writable") unless File.writable? conference.get_recordings_path
    errors.add(:original_url, 'missing original_url') if original_url.nil?
    not errors.any?
  end

  def unique_recording
    unless event.present?
      errors.add :event, 'missing event on recording'
      return
    end
    dupe = event.recordings.select { |recording|
      recording.filename == filename && recording.folder == folder
    }.delete_if { |dupe| dupe == self }
    errors.add :event, 'recording already exist on event' if dupe.present?
  end

  def min_width(maxwidth=nil)
    width = 1280
    width = [width, self.width.to_i].min if self.width
    width = [width, maxwidth.to_i].min if maxwidth
    width.to_i
  end

  def min_height(maxheight=nil)
    height = 720
    height = [height, self.height.to_i].min if self.height
    height = [height, maxheight.to_i].min if maxheight
    height.to_i
  end

  private

  def delete_recording_views
    recording_views.delete_all
  end

  def update_conference_downloaded_count
    conference.update_column :downloaded_events_count, Event.recorded_at(conference).to_a.size
  end

  def update_event_downloaded_count
    event.update_column :downloaded_recordings_count, event.downloaded_recordings.count
  end

  def update_event_duration
    event.update duration: event.duration_from_recordings
  end

  def update_event_language
    event.update original_language: event.original_language_from_recordings
  end
end
