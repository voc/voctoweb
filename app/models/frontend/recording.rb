module Frontend
  class Recording < ::Recording
    belongs_to :event, class_name: Frontend::Event
    scope :by_mime_type, ->(mime_type) { where(mime_type: mime_type) }
    scope :audio, -> { where(mime_type: MimeType::AUDIO) }
    scope :subtitle, -> { where(mime_type: MimeType::SUBTITLE) }

    def url
      File.join(event.conference.recordings_url, folder || '', filename).freeze
    end

    def resolution
      if width <= 320
        'sd'
      elsif width > 320 && width <= 720
        'hd'
      elsif width > 720 && width <= 1920
        'full-hd'
      elsif width > 1920
        '4k'
      end
    end

    def filetype
      MimeType.humanized_mime_type(mime_type)
    end
  end
end
