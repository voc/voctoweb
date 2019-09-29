
module Types
  class ConferenceType < Types::BaseObject
    description "This entity groups multiple lectures together, e.g. a Conference or Lecture Series"
    field :id, ID, null: false 
    field :title, String, "The title of this conference", null: false
    field :slug, String, "The URL slug of this conference", null: false 
    field :lectures, [Types::LectureType], null: true

    #field :logo, Types::ImageType, null: true
    field :logoUrl, UrlType, "A URL pointing to the conference's logo", null: true
    field :aspectRatio, String, "The aspect ratio of the conference's recordings", null: false # TODO: Enum
    field :recordingsUrl, UrlType,  "A URL pointing to the root of all recording files of this conference", null: false
    field :scheduleUrl, UrlType,  "A URL pointing to the conference's frab xml schedule", null: true
    field :updatedAt, DateTimeType, "Identifies the date and time when the object was last updated", null: false
    field :eventLastReleasedAt, DateTimeType, "Identifies the date and time when a event was last released", null: true


    def id
      object.acronym
    end
    def lectures
      object.events
    end
    def logo_url
      object.logo
    end
  end
end
