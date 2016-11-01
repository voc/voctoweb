class Event < ApplicationRecord
  include Recent
  include FahrplanUpdater
  include Storage
  include ElasticsearchEvent

  MAX_PROMOTED = 10

  belongs_to :conference
  has_many :recordings, dependent: :destroy
  has_many :video_recordings, -> {
    where(html5: true, mime_type: MimeType::VIDEO)
  }, class_name: Recording

  after_initialize :generate_guid

  validates :conference, :release_date, :slug, :title, :guid, :original_language, presence: true
  validates :guid, :slug, uniqueness: true
  validate :original_language_valid

  serialize :persons, Array
  serialize :tags, Array

  scope :recorded_at, ->(conference) {
    joins(:recordings, :conference)
      .where(conferences: { id: conference })
      .where(recordings: { mime_type: MimeType.all })
      .group(:id)
  }

  has_attached_file :thumb, via: :thumb_filename, belongs_into: :images, on: :conference

  has_attached_file :poster, via: :poster_filename, belongs_into: :images, on: :conference

  before_save { trim_paths }

  # active admin and serialized fields workaround:
  attr_accessor :persons_raw, :tags_raw

  after_save { conference.touch unless view_count_changed? }

  def generate_guid
    self.guid ||= SecureRandom.uuid
  end

  # run daily maybe, or as required
  def self.update_promoted_from_view_count
    connection.execute %( UPDATE events SET promoted = 'false' )
    popular_event_ids.each do |event_id|
      event = Event.find event_id['id']
      event.update_column :promoted, true
    end
  end

  # runs every 15 minutes by whenever
  def self.update_view_counts
    event_ids = recently_viewed_event_ids
    return unless event_ids.present?
    connection.execute %{
      UPDATE events
      SET view_count = (
        SELECT count(*)
        FROM recording_views
          JOIN recordings
            ON recording_views.recording_id = recordings.id
            AND recordings.event_id         = events.id
      )
      WHERE events.id IN (#{event_ids.join(',')})
    }
    event_ids.map { |id| Event.find(id).touch }
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

  def self.popular_event_ids
    connection.execute %{
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
  end

  def self.recently_viewed_event_ids
    RecordingView.joins(:recording).where('recording_views.updated_at > ?', Time.now.ago(30.minutes)).pluck('recordings.event_id').uniq
  end

  def original_language_valid
    return unless original_language
    languages = original_language.split('-')
    errors.add(:original_language, 'not a valid language') unless languages.all? { |l| Languages.all.include?(l) }
  end

  def get_image_filename(url)
    if url
      File.basename URI(url).path
    else
      ''
    end
  end

  def trim_paths
    thumb_filename.strip! unless thumb_filename.blank?
    poster_filename.strip! unless poster_filename.blank?
    link.strip! unless link.blank?
  end
end
