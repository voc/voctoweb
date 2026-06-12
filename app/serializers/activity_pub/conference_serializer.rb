class ActivityPub::ConferenceSerializer < ActivityPub::Serializer
  include Rails.application.routes.url_helpers

  # Define context with namespaces
  context :security
  context_extensions :sc, :collection, :items, :total_items

  # Define the attributes to include in the ActivityPub representation
  attributes :id, :type, :to, :name, :summary,
             # :start_date, :end_date, :location, :organizer,
             :url, :updated, :total_items

  # Define has_one and has_many relationships
  has_many :image, serializer: ActivityPub::ImageSerializer
  has_many :items, serializer: ActivityPub::EventSerializer

  def id
    conference_url(acronym: object.acronym)
  end

  def type
    'Collection'
  end

  def to
    ['https://www.w3.org/ns/activitystreams#Public']
  end

  def name
    object.title
  end

  def summary
    object.description
  end

=begin
  def start_date
    object.schedule_data&.fetch('conference', {})&.fetch('start', nil)
  end

  def end_date
    object.schedule_data&.fetch('conference', {})&.fetch('end', nil)
  end

  def location
    object.schedule_data&.fetch('conference', {})&.fetch('venue', nil)
  end

  def organizer
    object.schedule_data&.fetch('conference', {})&.fetch('organizer', nil)
  end
=end

  def url
    conference_url(object)
  end

  def updated
    object.updated_at&.iso8601
  end

  def image
    return [] unless object.logo_url.present?

    [
      ActivityPub::Image.new(
        url: object.logo_url,
        media_type: 'image/png'
      )
    ]
  end

  def items
    object.events
  end

  def total_items
    object.events.count
  end

  # Helper serializers

  class ActivityPub::ConferenceEventSerializer < ActivityPub::Serializer
    include Rails.application.routes.url_helpers

    attributes :type, :id, :name, :url, :duration, :published, :thumbnail

    def type
      'Video'
    end

    def id
      event_url(slug: object.slug)
    end

    def name
      object.title
    end

    def url
      object.frontend_link
    end

    def duration
      "PT#{object.duration}S"
    end

    def published
      object.release_date&.iso8601
    end

    def thumbnail
      object.thumb_url
    end
  end
end
