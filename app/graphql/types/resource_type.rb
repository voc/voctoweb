module Types
  class ResourceType < Types::BaseObject
    description "Files like videos, audios, SRTs or PDFs"

    field :label, String, null: false
    field :filename, String, null: false
    field :url, String, "A URL pointing to the CDN location of this recording", null: false
    field :language, String, "The recordings's language, encoded as ISO 639-2", null: true
    field :duration, Integer, "The recordings's duration in seconds", null: false
    field :mime_type, String, "The recordings's mime type, e.g. video/mp4", null: false
    field :width, Integer, "The width of this recording in px, if it is a video", null: false
    field :height, Integer, "The height of this recording in px, if it is a video", null: false
    field :high_quality, Boolean, "Whether this recording is a video with at least 720p resolution", null: false
    field :size, Integer, description: "The recording's approximate size, in the unit given by `unit` (defaults to megabytes)", null: false do
      argument :unit, SizeUnitType, "The unit to express the size in", required: false, default_value: 'MB'
    end
    field :updated_at, DateTimeType, "Identifies the date and time when the object was last updated", null: false

    #field :conference, Conference, "The conference this event belongs to"
    #field :event, Event, "The event this recording belongs to"

    def url
      object.get_recording_url
    end

    def size(unit:)
      case unit
      when 'GB'
        (object.size_gb || 0).round
      when 'BYTE'
        object.size || 0
      else
        (object.size_mb || 0).round
      end
    end

    def duration
      object.length
    end
  end
end
