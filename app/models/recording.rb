class Recording < ActiveRecord::Base
  include Recent
  include Storage
  include AASM

  belongs_to :event
  has_one :conference, through: :event
  has_many :recording_views

  validates :event, :filename, :mime_type, :length, :language, presence: true
  validates :width, :height, presence: true, if: :video?
  validates :folder, length: { minimum: 0, allow_nil: false, message: "can't be nil" }
  validates :mime_type, inclusion: { in: MimeType.all }
  validates :language, inclusion: { in: Event::LANGUAGES }
  validate :unique_recording
  validate :filename_without_path

  scope :downloaded, -> { where(state: 'downloaded') }
  scope :video, -> { where(mime_type: MimeType::VIDEO) }
  scope :audio, -> { where(mime_type: MimeType::AUDIO) }
  scope :html5, -> { where(html5: true) }

  after_save { update_conference_downloaded_count if downloaded? }
  after_save { update_event_downloaded_count if downloaded? }
  after_save { update_event_duration if length_changed? }
  after_save { event.touch }
  after_destroy { delete_recording_views }
  after_destroy { update_conference_downloaded_count if downloaded? }
  after_destroy { update_event_downloaded_count if downloaded? }
  after_destroy { event.touch }

  has_attached_file :recording, via: :filename, folder: :folder, belongs_into: :recordings, on: :conference

  aasm column: :state do
    state :new, initial: true
    state :downloaded
  end

  def video?
    mime_type.in? MimeType::VIDEO
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

  def min_width(maxwidth = nil)
    width = 1280
    width = [width, self.width.to_i].min if self.width
    width = [width, maxwidth.to_i].min if maxwidth
    width.to_i
  end

  def min_height(maxheight = nil)
    height = 720
    height = [height, self.height.to_i].min if self.height
    height = [height, maxheight.to_i].min if maxheight
    height.to_i
  end

  private

  def filename_without_path
    return unless filename
    errors.add :filename, 'not allowed to contain a path' if File.basename(filename) != filename
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
end
