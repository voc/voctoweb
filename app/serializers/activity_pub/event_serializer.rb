require_relative 'helper'

class ActivityPub::EventSerializer < ActivityPub::Serializer
  include Rails.application.routes.url_helpers

  # Define context with namespaces
  context :security
  context_extensions :pt, :sc, :sensitive, :language, :views

  # Define the attributes to include in the ActivityPub representation
  attributes :id, :type, :uuid, :to, :name, :media_type, :content,
             :duration, :views, :sensitive, :published, :updated

  # Define has_one and has_many relationships
  has_one :language, serializer: ActivityPub::LanguageSerializer
  has_many :attributed_to, serializer: ActivityPub::PersonSerializer
  has_many :tag, serializer: ActivityPub::HashtagSerializer
  has_many :icon, serializer: ActivityPub::ImageSerializer
  has_many :url, serializer: ActivityPub::LinkSerializer

  def id
    event_url(slug: object.slug)
  end

  def type
    'Video'
  end

  def uuid
    object.guid
  end

  def to
    ['https://www.w3.org/ns/activitystreams#Public']
  end

  def name
    object.title
  end

  def attributed_to
    object.persons.map { |person_name| ActivityPub::Person.new(name: person_name) }
  end

  def media_type
    'text/markdown'
  end

  def content
    object.description
  end

  def duration
    "PT#{object.duration}S"
  end

  def views
    object.view_count
  end

  def sensitive
    false
  end

  def published
    object.release_date&.iso8601
  end

  def updated
    object.updated_at&.iso8601
  end

  def language
    {
      identifier: object.original_language,
      name: Languages.to_string(object.original_language)
    }
  end

  def tag
    object.tags.reject(&:blank?).map { |tag| { name: tag } }
  end

  def icon
    [
      ActivityPub::Image.new(
        url: object.thumb_url,
        media_type: 'image/jpeg',
        width: 400,
        height: 225
      ),
      ActivityPub::Image.new(
        url: object.poster_url,
        media_type: 'image/jpeg',
        width: 1920,
        height: 1080
      )
    ]
  end

  def url
    urls = [
      {
        media_type: 'text/html',
        href: object.frontend_link
      },
      {
        rel: ['metadata'],
        media_type: 'application/json',
        href: object.url
      }
    ]

    # Add recording URLs
    if object.recordings.present?
      object.recordings.each do |recording|
        # Only add video URLs
        if recording.mime_type.start_with?('video/')
          urls << {
            media_type: recording.mime_type,
            href: recording.recording_url,
            height: recording.height,
            size: recording.size,
            fps: 25 # Default value since we don't have FPS information
          }

          # Add metadata link
          urls << {
            rel: ['metadata', recording.mime_type],
            height: recording.height,
            media_type: 'application/json',
            href: recording.url
          }
        end
      end
    end

    urls
  end
end
