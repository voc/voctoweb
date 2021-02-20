class Recording < ApplicationRecord
  include Recent
  include Storage

  belongs_to :event
  has_one :conference, through: :event
  has_many :recording_views, dependent: :delete_all

  validates :event, :filename, :mime_type,  :language, presence: true
  validates :length, presence: true, if: :requires_length
  validates :width, :height, presence: true, if: :video?
  validates :folder, length: { minimum: 0, allow_nil: false, message: "can't be nil" }
  validates :mime_type, inclusion: { in: MimeType.all }
  validates :language, inclusion: { in: Languages.all }, if: :html5?
  validates :language, exclusion: { in: %w(orig) }, unless: :subtitle?
  validate :language_valid, unless: :html5?
  validate :unique_recording
  validate :filename_without_path

  attr_accessor :dupe

  scope :video, -> { where(mime_type: MimeType::VIDEO) }
  scope :audio, -> { where(mime_type: MimeType::AUDIO) }
  scope :slides, -> { where("folder LIKE '%slides%'") }
  scope :without_slides, -> { where("folder NOT LIKE '%slides%'") }
  scope :video_without_slides, -> { video.where("folder NOT LIKE '%slides%'") }
  scope :subtitle, -> { where(mime_type: MimeType::SUBTITLE) }
  scope :html5, -> { where(html5: true) }
  scope :original_language, -> { joins(:event).where('events.original_language = recordings.language') }

  after_save { conference.update_downloaded_count! }
  after_save { update_event_downloaded_count }
  after_save { update_event_duration if saved_change_to_length? }
  after_save { event.touch }
  after_destroy { conference.update_downloaded_count! }
  after_destroy { update_event_downloaded_count }
  after_destroy { event.touch }
  before_save { trim_paths }

  has_attached_file :recording, via: :filename, folder: :folder, belongs_into: :recordings, on: :conference

  def video?
    mime_type.in? MimeType::VIDEO
  end

  def audio?
    mime_type.in? MimeType::AUDIO
  end

  def requires_length
    self.video? || self.audio?
  end

  def slides?
    folder.start_with?('slides')
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

  def display_filetype
    display_filetypes = {
      'webm' => 'WebM',
      'mp4' => 'MP4',
      'mp3' => 'MP3',
      'ogg' => 'Ogg',
      'opus' => 'Opus',
      'pdf' => 'PDF',
      'srt' => 'SRT',
      'vtt' => 'WebVTT',
    }

    if display_filetypes.key?(filetype)
      display_filetypes[filetype]
    else
      filetype
    end
  end

  def label
    if slides?
      "slides #{language} #{height}p"
    elsif subtitle?
      if state != 'complete'
        "#{language} (#{state})"
      else
        "#{language}"
      end
    else
      "#{language} #{height}p"
    end
  end

  def quality_label
    high_quality ? 'high' : 'low'
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

  def number_of_pixels()
    height.to_i * width.to_i
  end

  def language_iso_639_1
    Languages.to_iso_639_1(language)
  end

  def language_label
    Languages.to_string(language)
  end

  def languages
    language.split('-')
  end

  def url
    if self.mime_type == 'text/vtt' 
      File.join(Settings.static_url, event.conference.images_path, filename).freeze 
    else
      File.join(event.conference.recordings_url, folder || '', filename).freeze
    end
  end

  def cors_url
    if self.mime_type == 'text/vtt' 
      File.join(Settings.static_url, event.conference.images_path, filename).freeze 
    else
      File.join(Settings.cors_url, event.conference.recordings_path, folder || '', filename).freeze
    end
  end

  # for elastic search
  def fulltext
    puts ' downloading ' + cors_url
    begin 
      URI.open(url).read if subtitle?
    rescue OpenURI::HTTPError
      puts '   failed with HTTP Error'
      ''
    end
  end

  private

  def language_valid
    return unless language
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

    if self.subtitle?
      self.dupe = event.recordings.select { |recording|
        recording.language == language && recording.folder == folder
      }.delete_if { |dupe| dupe == self }
    else
      self.dupe = event.recordings.select { |recording|
        recording.filename == filename && recording.folder == folder
      }.delete_if { |dupe| dupe == self }
    end 

    if self.dupe.present?
      errors.add :event, 'recording already exist on event'
    end
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
