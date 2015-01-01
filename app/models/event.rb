class Event < ActiveRecord::Base
  include Recent
  include FahrplanUpdater
  include Download
  include Storage

  MAX_PROMOTED = 10

  belongs_to :conference
  has_many :recordings, dependent: :destroy

  after_initialize :generate_guid

  validates_presence_of :conference
  validates_presence_of :release_date, :slug, :title
  validates_presence_of :guid
  validates_uniqueness_of :guid

  serialize :persons, Array
  serialize :tags, Array

  scope :recorded_at, ->(conference) {
    joins(:recordings, :conference)
      .where(conferences: { id: conference })
      .where(recordings: { state: 'downloaded', mime_type: MimeType::HTML5 })
      .group(:"events.id")
  }

  scope :by_identifier, ->(webgen_location, slug) {
    joins(:conference).where(conferences: {webgen_location: webgen_location}, events: {slug: slug}).first
  }

  has_attached_file :thumb, via: :thumb_filename, belongs_into: :images, on: :conference

  has_attached_file :poster, via: :poster_filename, belongs_into: :images, on: :conference

  # active admin and serialized fields workaround:
  attr_accessor   :persons_raw, :tags_raw

  def generate_guid
    self.guid ||= SecureRandom.uuid
  end

  def self.update_promoted_from_view_count
    self.connection.execute %{ UPDATE events SET promoted = 'false' }
    popular_event_ids = self.connection.execute %{
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
    self.persons.join("\n") unless self.persons.nil?
  end

  # active admin and serialized fields workaround:
  def persons_raw=(values)
    self.persons = []
    self.persons = values.split("\n").map { |w| w.strip }
  end

  # active admin and serialized fields workaround:
  def tags_raw
    self.tags.join("\n") unless self.tags.nil?
  end

  # active admin and serialized fields workaround:
  def tags_raw=(values)
    self.tags = []
    self.tags = values.split("\n").map { |w| w.strip }
  end

  def get_recording_by_mime_type(type)
    self.recordings.where(mime_type: type)
  end

  def length
    self.recordings.max { |e| e.length }.try(:length)
  end

  def set_image_filenames(thumb_url, poster_url)
    self.thumb_filename = get_image_filename thumb_url if thumb_url
    self.poster_filename = get_image_filename poster_url if poster_url
  end

  def download_images(thumb_url, poster_url)
    FileUtils.mkdir_p self.conference.get_images_path
    self.delay.download_image(thumb_url, thumb_filename)
    self.delay.download_image(poster_url, poster_filename)
  end

  def download_image(url, filename)
    return if url.nil? or filename.nil?
    path = File.join self.conference.get_images_path, filename
    download_to_file(url, path)
  end

  def display_name
    if self.title.present?
      self.conference.acronym + ": " + self.title
    else
      self.guid || self.id
    end
  end

  # TODO copied from frontend
  def persons_text
    if self.persons.length == 0
      'n/a'
    elsif self.persons.length == 1
      self.persons[0]
    else
      persons = self.persons[0..-3] + [self.persons[-2..-1].join(' and ')]
      persons.join(', ')
    end
  end

  private

  def get_image_filename(url)
    if url
      File.basename URI(url).path
    else
      ""
    end
  end

end
