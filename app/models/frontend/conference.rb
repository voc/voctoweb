module Frontend
  class Conference < ::Conference
    has_many :events, class_name: Frontend::Event

    def mime_types
      Recording.recorded_at(self).pluck(:mime_type).uniq.map { |mime_type|
        yield mime_type, MimeType.mime_type_slug(mime_type)
      }
    end

    def preferred_mime_type
      available = Recording.recorded_at(self).pluck(:mime_type).uniq
      MimeType::PREFERRED_VIDEO.each { |mime_type|
        return MimeType.mime_type_slug(mime_type) if available.include? mime_type
      }
      return MimeType.mime_type_slug(available.first)
    end

    def recordings_url
      File.join Settings.cdnURL, self.recordings_path
    end
  end
end
