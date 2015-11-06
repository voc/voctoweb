class Event < ActiveRecord::Base
  include Recent
  include FahrplanUpdater
  include Storage

  MAX_PROMOTED = 10

  belongs_to :conference
  has_many :recordings, dependent: :destroy
  has_many :downloaded_recordings, -> {
    where(state: 'downloaded', mime_type: MimeType::HTML5)
  }, class_name: Recording

  after_initialize :generate_guid

  validates_presence_of :conference
  validates_presence_of :release_date, :slug, :title
  validates_presence_of :guid
  validates_uniqueness_of :guid
  validates_uniqueness_of :slug

  serialize :persons, Array
  serialize :tags, Array

  scope :recorded_at, ->(conference) {
    joins(:recordings, :conference)
      .where(conferences: { id: conference })
      .where(recordings: { state: 'downloaded', mime_type: MimeType::HTML5 })
      .group(:id)
  }

  scope :by_conference_slug, ->(conference_slug, slug) {
    joins(:conference).where(conferences: { slug: conference_slug }, events: { slug: slug })
  }

  has_attached_file :thumb, via: :thumb_filename, belongs_into: :images, on: :conference

  has_attached_file :poster, via: :poster_filename, belongs_into: :images, on: :conference

  # active admin and serialized fields workaround:
  attr_accessor :persons_raw, :tags_raw

  after_save { conference.touch unless view_count_changed? }

  def generate_guid
    self.guid ||= SecureRandom.uuid
  end

  def self.by_identifier(conference_slug, slug)
    event = by_conference_slug(conference_slug, slug).try(:first)
    fail ActiveRecord::RecordNotFound, "#{conference_slug}/#{slug}" unless event
    event
  end

  def self.update_promoted_from_view_count
    connection.execute %( UPDATE events SET promoted = 'false' )
    popular_event_ids = connection.execute %{
      SELECT events.id
        FROM events
        JOIN recordings
          ON recordings.event_id          = events.id
        JOIN recording_views
          ON recording_views.recording_id = recordings.id
      WHERE recording_views.created_at    > '#{Time.now.ago 1.week}'
      GROUP BY events.id
      ORDER BY count(recording_views.id) DESC LIMIT #{MAX_PROMOTED}
    }
    popular_event_ids.each do |event_id|
      event = Event.find event_id['id']
      event.promoted = true
      event.save
    end
  end

  # active admin and serialized fields workaround:
  def persons_raw
    persons.join("\n") unless persons.nil?
  end

  # active admin and serialized fields workaround:
  def persons_raw=(values)
    self.persons = []
    self.persons = values.split("\n").map(&:strip)
  end

  # active admin and serialized fields workaround:
  def tags_raw
    tags.join("\n") unless tags.nil?
  end

  # active admin and serialized fields workaround:
  def tags_raw=(values)
    self.tags = []
    self.tags = values.split("\n").map(&:strip)
  end

  def duration_from_recordings
    recordings.maximum(:length) || 0
  end

  def set_image_filenames(thumb_url, poster_url)
    self.thumb_filename = get_image_filename thumb_url if thumb_url
    self.poster_filename = get_image_filename poster_url if poster_url
  end

  def download_images(thumb_url, poster_url)
    download_image(thumb_url, thumb_filename)
    download_image(poster_url, poster_filename)
  end

  def display_name
    if title.present?
      conference.acronym + ': ' + title
    else
      self.guid || id
    end
  end

  def persons_text
    if persons.length == 0
      'n/a'
    elsif persons.length == 1
      persons[0]
    else
      persons = self.persons[0..-3] + [self.persons[-2..-1].join(' and ')]
      persons.join(', ')
    end
  end

  private

  def download_image(url, filename)
    return if url.nil? or filename.nil?
    DownloadWorker.perform_async(conference.get_images_path, filename, url)
  end

  def get_image_filename(url)
    if url
      File.basename URI(url).path
    else
      ''
    end
  end
end
