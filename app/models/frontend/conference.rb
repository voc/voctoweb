module Frontend
  class Conference < ::Conference
    has_many :events, class_name: 'Frontend::Event'
    has_many :recordings, through: :events

    scope :with_events, ->() {
      where('event_last_released_at IS NOT NULL')
    }
    scope :with_recent_events, ->() {
      where('event_last_released_at IS NOT NULL')
        .order('event_last_released_at DESC')
    }
    scope :with_events_newer, ->(date) {
      where('event_last_released_at IS NOT NULL')
        .order('event_last_released_at DESC')
        .where('event_last_released_at > ?', date)
    }
    scope :with_events_older, ->(date) {
      where('event_last_released_at IS NOT NULL')
        .order('event_last_released_at DESC')
        .where('event_last_released_at < ?', date)
    }
    scope :isCurrentlyStreaming, ->() {
      where('(streaming ->> :key)::boolean', key: 'isCurrentlyStreaming')
    }

    def self.has_live?
      Conference.isCurrentlyStreaming.any?
    end

    def self.first_live
      Conference.isCurrentlyStreaming.first
    end

    def self.live
      conferences = Conference.isCurrentlyStreaming
      groups = conferences.map { |c| c.streaming['groups'].first }.compact
      groups.map { |g| g['rooms'] }.flatten
    end

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
