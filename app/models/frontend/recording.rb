module Frontend
  class Recording < ::Recording
    belongs_to :event, class_name: Frontend::Event
    scope :by_mime_type, ->(mime_type) { where(mime_type: mime_type) }

    def url
      File.join(event.conference.recordings_url, folder || '', filename).freeze
    end

    def cors_url
      File.join(Settings.cors_url, event.conference.recordings_path, folder || '', filename).freeze
    end

    def resolution
      return '' unless height
      if height < 720
        'sd'
      elsif height < 1080
        'hd'
      elsif height < 1716
        'full-hd'
      else
        '4k'
      end
    end

    def filetype
      MimeType.humanized_mime_type(mime_type)
    end
  end
end
