module Types
  class ConferenceType < Types::BaseObject
    description "This entity groups multiple lectures together, e.g. a Conference or Lecture Series"
    field :id, ID, null: false
    field :acronym, SlugType, "The acronym of this conference, used as its identifier", null: false
    field :title, String, "The title of this conference", null: false
    field :slug, SlugType, "The URL slug of this conference", null: false
    field :lectures, LectureType.connection_type, null: true

    field :url, UrlType, "A URL pointing to the conference page in vocotweb frontend", null: false
    field :link, UrlType, "A URL pointing to the conference's own website", null: true
    field :description, String, "The conference's description", null: true
    field :logo_url, UrlType, "A URL pointing to the conference's logo", null: true, deprecation_reason: "Use the `logo` field instead"
    field :logo, Types::ImageType, "The conference's logo", null: true do
      argument :prefer, Types::ImageMimeTypeEnum, required: false
    end
    field :images, [Types::ImageType], "All images assigned to this conference, includes banner, logos in light & dark variants, etc.", null: false

    field :images_url, UrlType, "A URL pointing to the root of all image files of this conference", null: false, deprecation_reason: "Use the `images` field instead"
    field :aspect_ratio, String, "The aspect ratio of the conference's recordings", null: false # TODO: Enum
    field :recordings_url, UrlType, "A URL pointing to the root of all recording files of this conference", null: false
    field :schedule_url, UrlType, "A URL pointing to the conference's frab xml schedule", null: true
    field :updated_at, DateTimeType, "Identifies the date and time when the object was last updated", null: false
    field :event_last_released_at, DateTimeType, "Identifies the date and time when a event was last released", null: true

    field :metadata_raw, JsonType, "The raw metadata for this conference, as stored in the database", null: true, deprecation_reason: "experimental"
    field :streaming_raw, JsonType, "The raw streaming information for this conference, as provided by streaming v2 API", null: true, deprecation_reason: "experimental"

    def id
      object.acronym
    end

    def lectures
      object.events
    end

    def url
      Rails.application.routes.url_helpers.conference_url(acronym: object.acronym)
    end

    def logo(prefer: nil)
      logo = object.logo_img
      return logo if prefer.blank? || logo.blank? || logo[:mime_type] == prefer

      object.images.each do |image|
        if image['type'] == 'logo' && image['mime_type'] == prefer
          return image
        end
      end

      # fallback to the default logo if no preferred variant is found
      logo
    end

    def images_url
      object.get_images_url
    end

    def recordings_url
      object.get_recordings_url
    end

    def metadata_raw
      object.metadata
    end

    def streaming_raw
      object.streaming
    end
  end
end
