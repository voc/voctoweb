
# This entity is an Event with multiple Files e.g. Video and Audio recordings, as well as PDFs e.g. the lecture slides
# alternate Name: Lecture, Talk?
module Types
  class LectureType < Types::BaseObject
    description 'This entity is an Event with multiple Files e.g. Video and Audio recordings, subtitles (SRT) as well as PDFs e.g. the lecture slides'

    field :guid, ID, null: false 
    field :localId, Integer, null: false
    # field :conference, Types::ConferenceType, "The conference this event belongs to", null: false

    field :title, String,  "The title of this event", null: false
    field :subtitle, String,  "The event's subtitle that may be displayed below the title", null: true
    field :description, String, "The event's description", null: true

    field :slug, UrlType, "The URL slug of this event", null: false
    field :originalLanguage, String, "The event's original language, encoded as ISO 639-2", null: true
    field :duration, Integer, "The lecture recording duration in seconds", null: true

    field :persons, [String], "Names of persons that held the event", null: true
    field :promoted, Boolean, "Whether the event is promoted right now", null: true
    field :tags, [String], "Tags/keywords describing the event", null: true

    field :date, DateTimeType, "Identifies the date and time when the event took place", null: true
    field :releaseDate, DateTimeType, "Identifies the date when the event got released", null: true
    field :updatedAt, DateTimeType, "Identifies the date and time when the object was last updated", null: true
    field :viewCount, Integer, "The amount of views of this event", null: true

    #field :shareUrl, UrlType, "URL pointing to the voctoweb page representing this entity", null: true
    field :link, UrlType, "URL pointing to the conference event website", null: true
    field :doiUrl, UrlType, "Digital Object Identifier (DOI) e.g. https://doi.org/10.5446/19566", null: true


    field :videoPreferred, AssetType, null: false
    field :videos, [AssetType], null: false
    field :audios, [AssetType], null: true
    field :subtitles, [AssetType], null: true
    field :slides, [AssetType], null: true
    field :files, AssetType.connection_type, null: false

    # field :thumbnail, Types::ImageType, null: true
    class LectureImageType < Types::BaseObject    
      field :posterUrl, UrlType, 'URL pointing to a preview/poster image of the event', null: true
      field :thumbUrl, UrlType, 'URL pointing to a smaller version of the poster image', null: true
    end
    field :images, LectureImageType, null: true
    def images 
      object
    end

    class LectureTimelensType < Types::BaseObject    
      field :timelineUrl, UrlType, 'URL pointing timelens timline image of the event', null: true
      field :thumbnailsUrl, UrlType, 'URL pointing to scrubbing thumbnails for timelens/timeline', null: true
    end
    field :timelens, LectureTimelensType, null: true
    def timelens 
      object
    end

    '''
    # A list of related events, ordered by decreasing relevance.
    relatedEvents(
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

    # is defined in fronend model
    def video_preferred
      object.preferred_recording
    end

    def audios
      object.recordings.audio
    end

    def subtitles
      object.recordings.subtitle
    end

    #def share_url
    #  public_event_url(object)
    #end
  end
end