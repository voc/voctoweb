module Frontend
  class Conference < ::Conference
    has_many :events, class_name: Frontend::Event
    has_many :recordings, through: :events
    has_many :downloaded_events, -> {
      joins(:recordings).where(recordings: { state: 'downloaded', mime_type: MimeType::HTML5 }).uniq
    }, class_name: Frontend::Event

    def mime_types
      return enum_for(:mime_types) unless block_given?
      recordings.pluck(:mime_type).uniq.map { |mime_type|
        yield mime_type, MimeType.mime_type_slug(mime_type)
      }
    end

    def recordings_url
      File.join Settings.cdn_url, recordings_path
    end
  end
end
