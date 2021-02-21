class Event < ApplicationRecord
  include FahrplanUpdater
  include Storage
  include ElasticsearchEvent

  MAX_PROMOTED = 10

  belongs_to :conference
  has_many :recordings, dependent: :destroy
  has_many :video_recordings, -> {
    where(html5: true, mime_type: MimeType::VIDEO)
  }, class_name: 'Recording'

  validates :conference, :slug, :title, :guid, :original_language, presence: true
  validates :slug, format: { with: %r{\A[^/]+\z} }
  validates :guid, :slug, uniqueness: true
  validates :doi, format: { with: %r{\A\b(10[.][0-9]{4,}(?:[.][0-9]+)*/(?:(?!["&\'<>])\S)+)\z}, message: 'doi format not valid' }, allow_blank: true
  validate :original_language_valid

  before_validation :strip_prefix, :only => [:doi]

  serialize :persons, Array
  serialize :tags, Array

  # get all Events of a Conference with at least one Recording
  scope :recorded_at, ->(conference) {
    # reuse conference so using event.conference does not trigger a query
    conference
      .events
      .includes(:recordings)
      .where.not(recordings: { id: nil })
  }
  scope :released, -> { where('release_date IS NOT NULL').order('release_date desc') }
  scope :newer, ->(date) { released.where('release_date > ?', date) }
  scope :older, ->(date) { released.where('release_date < ?', date) }
  scope :recent, ->(n) { released.limit(n) }

  has_attached_file :thumb, via: :thumb_filename, belongs_into: :images, on: :conference

  has_attached_file :poster, via: :poster_filename, belongs_into: :images, on: :conference

  has_attached_file :timeline, via: :timeline_filename, belongs_into: :images, on: :conference

  has_attached_file :thumbnails, via: :thumbnails_filename, belongs_into: :images, on: :conference

  after_initialize :generate_guid
  before_save { trim_paths }
  after_save { conference.update_last_released_at_column if saved_change_to_release_date? }
  after_save { update_conference_downloaded_count if saved_change_to_conference_id? }
  after_save { conference.touch unless saved_change_to_view_count? }
  after_save { update_feeds unless saved_change_to_view_count? }
  after_touch { conference.touch }
  after_destroy { |record| delete_related_from_other_events(record.id.to_s) }
  after_destroy { conference.update_last_released_at_column }
  after_destroy { conference.touch }

  # active admin and serialized fields workaround:
  attr_accessor :persons_raw, :tags_raw

  def generate_guid
    self.guid ||= SecureRandom.uuid
  end

  # run daily maybe, or as required
  def self.update_promoted_from_view_count
    connection.execute %( UPDATE events SET promoted = 'false' )
    popular_event_ids.each do |event_id|
      event = Event.find event_id['id']
      unless event.promotion_disabled
        event.update_column :promoted, true
      end
    end
  end

  # runs every 15 minutes by whenever
  def self.update_view_counts
    event_ids = recently_viewed_event_ids
    return unless event_ids.present?
    view_count_updated_at = EventViewCount.updated_at
    connection.execute %{
      UPDATE events
      SET view_count = view_count + (
        SELECT count(*)
        FROM recording_views
          JOIN recordings
            ON recording_views.recording_id = recordings.id
            AND recordings.event_id         = events.id
            AND recording_views.created_at > #{connection.quote(view_count_updated_at)}
      )
      WHERE events.id IN (#{event_ids.join(',')})
    }
    EventViewCount.touch!
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

  def set_image_filenames(thumb_url, poster_url, timeline_url, thumbnails_url)
    self.thumb_filename = get_image_filename thumb_url if thumb_url
    self.poster_filename = get_image_filename poster_url if poster_url
    self.timeline_filename = get_image_filename timeline_url if timeline_url
    self.thumbnails_filename = get_image_filename thumbnails_url if thumbnails_url
  end

  def display_name
    if title.present?
      conference.acronym + ': ' + title
    else
      self.guid || id
    end
  end

  def persons_text
    if persons.length.zero?
      'n/a'
    elsif persons.length == 1
      persons[0]
    else
      persons = self.persons[0..-3] + [self.persons[-2..-1].join(' and ')]
      persons.join(', ')
    end
  end

  def related_events
    unless metadata['related'].nil?
      ids = metadata['related'].keys
      Frontend::Event.includes([:conference]).find(ids)
    end
  end

  # we can not use promotion_disabled? as method name, due to activeadmin
  def promotion_disabled
    self&.metadata&.fetch('promotion_disabled', false)
  end

  def promotion_disabled=(val)
    if val == '1'
      self[:metadata]['promotion_disabled'] = true
    else
      self[:metadata].delete('promotion_disabled')
    end
  end

  # for elastic search
  def remote_id
    metadata['remote_id']
  end

  # used by player and graphql
  def videos_sorted_by_language
    recordings.video
              .sort_by(&:mime_type)
              .sort_by { |x|
                (x.language == original_language ? -5 : 0) +
                  (x.html5 ? -2 : 0) -
                  (x.width)
              }
  end

  def subtitles
    recordings.subtitle
              .sort_by { |x| (x.language == original_language ? -5 : 0)}
  end

  def subtitle_edit_url
    'https://www.c3subtitles.de/talk/guid/' + guid
  end

  def doi_url
    "https://doi.org/#{doi}" if doi
  end

  def video_master
    recordings.video_without_slides
              .select { |x| x.filetype == 'video/mp4' && x.high_quality == true }
              .min_by { |x| x.html5 ? 1 : 0 }
  end

  def translations
    video_master.languages - [ original_language ]
  end


  def update_feeds
    return unless release_date

    # also update these daily
    if release_date > WebFeed.last_year
      Feed::PodcastWorker.perform_async
      Feed::LegacyWorker.perform_async
      Feed::AudioWorker.perform_async
    elsif release_date < WebFeed.last_year
      Feed::ArchiveWorker.perform_async
      Feed::ArchiveLegacyWorker.perform_async
    end

    # these don't need to be re-created periodically
    Feed::FolderWorker.perform_async conference.id
    Feed::RecentWorker.perform_async
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
  private_class_method :popular_event_ids

  def self.recently_viewed_event_ids
    RecordingView.joins(:recording).where('recording_views.updated_at > ?', Time.now.ago(30.minutes)).pluck('recordings.event_id').uniq
  end
  private_class_method :recently_viewed_event_ids

  def update_conference_downloaded_count
    conference.update_downloaded_count!
    begin
      Conference.find(attribute_before_last_save(:conference_id)).update_downloaded_count!
    rescue ActiveRecord::RecordNotFound
      # could have vanished and it's ok
    end
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
    timeline_filename.strip! unless timeline_filename.blank?
    thumbnails_filename.strip! unless thumbnails_filename.blank?
    link.strip! unless link.blank?
  end

  def strip_prefix
    self.doi = doi.sub(/^https?:\/\/doi\.org\//, '') unless doi.nil?
  end

  def delete_related_from_other_events(id)
    Event.where("metadata->'related' ? :value", value: id).each do |event|
      event.metadata['related'].delete(id)
      event.update_columns(metadata: event.metadata)
    end
  end
end
