module Frontend
  class Recording < ::Recording
    belongs_to :event, class_name: 'Frontend::Event'
    scope :by_mime_type, ->(mime_type) { where(mime_type: mime_type) }

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
