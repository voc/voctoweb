module Frontend
  class Conference < ::Conference
    has_many :events, class_name: Frontend::Event
    has_many :recordings, through: :events

    scope :with_events, ->() {
      joins(:events)
        .group('conferences.id')
    }
    scope :with_recent_events, ->() {
      joins(:events)
        .group('conferences.id')
        .order('MAX(events.release_date) desc')
    }
    scope :with_events_newer, ->(date) {
      joins(:events)
        .group('conferences.id')
        .having('MAX(events.release_date) > ?', date)
        .order('MAX(events.release_date) desc')
    }
    scope :with_events_older, ->(date) {
      joins(:events)
        .group('conferences.id')
        .having('MAX(events.release_date) < ?', date)
        .order('MAX(events.release_date) desc')
    }

    def mime_types
      return enum_for(:mime_types) unless block_given?
      recordings.pluck(:mime_type).uniq.map { |mime_type|
        yield mime_type.freeze, MimeType.mime_type_slug(mime_type)
      }
    end

    def recordings_url
      File.join(Settings.cdn_url, recordings_path).freeze
    end
  end
end
