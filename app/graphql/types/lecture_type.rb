# This entity is an Event with multiple Files e.g. Video and Audio recordings, as well as PDFs e.g. the lecture slides
# alternate Name: Lecture, Talk?

module Types
  class LectureType < Types::BaseObject
    description 'This entity is an Event with multiple Files e.g. Video and Audio recordings, subtitles (SRT) as well as PDFs e.g. the lecture slides'

    field :guid, ID, null: false
    field :local_id, Integer, null: false
    field :conference, Types::ConferenceType, "The conference this event belongs to", null: false

    field :title, String, "The title of this event", null: false
    field :subtitle, String, "The event's subtitle that may be displayed below the title", null: true
    field :description, String, "The event's description", null: true

    field :slug, SlugType, "The URL slug of this event", null: false
    field :url, UrlType, "A URL pointing to this lecture's page in vocotweb frontend", null: false

    field :original_language, String, "The event's original language, encoded as ISO 639-2", null: true
    field :translations, [String], "The languages this event has been translated into, encoded as ISO 639-2", null: true
    field :duration, Integer, "The lecture recording duration in seconds", null: true

    field :persons, [String], "Names of persons that held the event", null: true
    field :promoted, Boolean, "Whether the event is promoted right now", null: true
    field :tags, [String], "Tags/keywords describing the event", null: true

    field :date, DateTimeType, "Identifies the date and time when the event took place", null: true
    field :release_date, DateTimeType, "Identifies the date when the event got released", null: true
    field :updated_at, DateTimeType, "Identifies the date and time when the object was last updated", null: true
    field :view_count, Integer, "The amount of views of this event", null: true

    #field :share_url, UrlType, "URL pointing to the voctoweb page representing this entity", null: true
    field :link, UrlType, "URL pointing to the conference event website", null: true
    field :doi_url, UrlType, "Digital Object Identifier (DOI) e.g. https://doi.org/10.5446/19566", null: true

    field :video_preferred, ResourceType, "simlified access to single language video in original language", null: false
    field :video, ResourceType, "main MP4 video, possibly with multiple audio and video tracks", null: false do
      argument :prefer, [Types::VideoPreferenceEnum], required: false
      argument :quality, Types::VideoQualityEnum, required: false
    end
    field :videos, [ResourceType], "all video recordings assigned to this item", null: false
    field :audios, [ResourceType], "all audio recordings assigned to this item", null: false
    field :subtitles, [ResourceType], null: false
    field :slides, [ResourceType], "PDF slides, if provided", null: false
    field :files, ResourceType.connection_type, null: false

    # field :thumbnail, Types::ImageType, null: true
    class LectureImageType < Types::BaseObject
      field :poster_url, UrlType, 'URL pointing to a preview/poster image of the event', null: true
      field :thumb_url, UrlType, 'URL pointing to a smaller version of the poster image', null: true
    end
    field :images, LectureImageType, null: false
    def images
      object
    end

    class LectureTimelensType < Types::BaseObject
      field :timeline_url, UrlType, 'URL pointing timelens timline image of the event', null: true
      field :thumbnails_url, UrlType, 'URL pointing to scrubbing thumbnails for timelens/timeline', null: true
    end
    field :timelens, LectureTimelensType, null: false
    def timelens
      object
    end

    field :player_config, JsonType, null: true
    def player_config
       { sources: object.clappr_sources, subtitles: object.clappr_subtitles }
    end

    field :relive, JsonType, null:true
    def relive
       object.relive if object.relive_present? and !object.recordings.video.present?
    end

    '''
    # A list of related events, ordered by decreasing relevance.
    relatedLectures(
      # Skip the first _n_ related events.
      offset: Integer

      # Limit the amount of returned related events.
      limit: Integer
    ): EventConnection!
    '''

    def local_id
      object.id
    end

    def files
      object.recordings
    end

    def videos
      object.videos_sorted_by_language
    end

    # is defined in frontend model
    def video_preferred
      object.preferred_recording
    end

    def video(prefer: nil, quality: nil)
      if prefer.present?
        result = object.recordings.video.find_by(mime_type: prefer)
        return result if result.present?
      end
      #object.recording_for_master_feed
      object.video_master
    end

    def audios
      object.recordings.audio
    end

    def subtitles
      object.recordings.subtitle
    end

    def url
      Rails.application.routes.url_helpers.event_url(slug: object.slug)
    end
  end
end
