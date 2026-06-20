module Types
  class ConferenceType < Types::BaseObject
    description "This entity groups multiple lectures together, e.g. a Conference or Lecture Series"
    field :id, ID, null: false
    field :acronym, String, "The acronym of this conference, used as its identifier", null: false
    field :title, String, "The title of this conference", null: false
    field :slug, String, "The URL slug of this conference", null: false
    field :lectures, LectureType.connection_type, null: true

    field :url, UrlType, "A URL pointing to the conference page in vocotweb frontend", null: false
    field :link, UrlType, "A URL pointing to the conference's own website", null: true
    field :description, String, "The conference's description", null: true
    #field :logo, Types::ImageType, null: true
    field :logo_url, UrlType, "A URL pointing to the conference's logo", null: true
    field :images_url, UrlType, "A URL pointing to the root of all image files of this conference", null: false
    field :aspect_ratio, String, "The aspect ratio of the conference's recordings", null: false # TODO: Enum
    field :recordings_url, UrlType, "A URL pointing to the root of all recording files of this conference", null: false
    field :schedule_url, UrlType, "A URL pointing to the conference's frab xml schedule", null: true
    field :updated_at, DateTimeType, "Identifies the date and time when the object was last updated", null: false
    field :event_last_released_at, DateTimeType, "Identifies the date and time when a event was last released", null: true

    def id
      object.acronym
    end

    def lectures
      object.events
    end

    def url
      Rails.application.routes.url_helpers.conference_url(acronym: object.acronym)
    end

    def images_url
      object.get_images_url
    end

    def recordings_url
      object.get_recordings_url
    end
  end
end
