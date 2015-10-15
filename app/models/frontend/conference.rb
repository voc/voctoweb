module Frontend
  class Conference < ::Conference
    has_many :events, class_name: Frontend::Event

    def mime_types
      return enum_for(:mime_types) unless block_given?
      Recording.recorded_at(self).pluck(:mime_type).uniq.map { |mime_type|
        yield mime_type, MimeType.mime_type_slug(mime_type)
      }
    end

    def recordings_url
      File.join Settings.cdnURL, self.recordings_path
    end
  end
end
