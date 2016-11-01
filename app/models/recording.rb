class Recording < ApplicationRecord
  include Recent
  include Storage

  belongs_to :event
  has_one :conference, through: :event
  has_many :recording_views, dependent: :delete_all

  validates :event, :filename, :mime_type, :length, :language, presence: true
  validates :width, :height, presence: true, if: :video?
  validates :folder, length: { minimum: 0, allow_nil: false, message: "can't be nil" }
  validates :mime_type, inclusion: { in: MimeType.all }
  validates :language, inclusion: { in: Languages.all }, if: :html5?
  validates :language, exclusion: { in: %w(orig) }, unless: :subtitle?
  validate :language_valid, unless: :html5?
  validate :unique_recording
  validate :filename_without_path

  scope :video, -> { where(mime_type: MimeType::VIDEO) }
  scope :audio, -> { where(mime_type: MimeType::AUDIO) }
  scope :subtitle, -> { where(mime_type: MimeType::SUBTITLE) }
  scope :html5, -> { where(html5: true) }
  scope :original_language, -> { joins(:event).where('events.original_language = recordings.language') }

  after_save { update_conference_downloaded_count }
  after_save { update_event_downloaded_count }
  after_save { update_event_duration if length_changed? }
  after_save { event.touch }
  after_destroy { update_conference_downloaded_count }
  after_destroy { update_event_downloaded_count }
  after_destroy { event.touch }
  before_save { trim_paths }

  has_attached_file :recording, via: :filename, folder: :folder, belongs_into: :recordings, on: :conference

  def video?
    mime_type.in? MimeType::VIDEO
  end

  def subtitle?
    mime_type.in? MimeType::SUBTITLE
  end

  def display_name
    str = if event.present?
            event.display_name
          else
            filename
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

  def language_iso_639_1
    Languages.to_iso_639_1(language)
  end

  private

  def language_valid
    return unless language
    languages = language.split('-')
    errors.add(:language, 'not a valid language') unless languages.all? { |l| Languages.all.include?(l) }
  end

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

  def update_conference_downloaded_count
    conference.update_column :downloaded_events_count, Event.recorded_at(conference).to_a.size
  end

  def update_event_downloaded_count
    event.update_column :downloaded_recordings_count, event.recordings.count
  end

  def update_event_duration
    event.update duration: event.duration_from_recordings
  end

  def trim_paths
    filename.strip! unless filename.blank?
    folder.strip! unless folder.blank?
  end
end
