module Frontend
  class Recording < ::Recording
    belongs_to :event, class_name: Frontend::Event
    scope :by_mime_type, ->(mime_type) { where(mime_type: mime_type) }
    scope :audio, -> { where(mime_type: %w[audio/ogg audio/mpeg audio/opus]) }

    def url
      File.join self.event.conference.recordings_url, self.folder || '', self.filename
    end

    def torrent_url
      url + '.torrent'
    end

    def display_mime_type
      MimeType.display_mime_type(mime_type)
    end

    def filetype
      MimeType.humanized_mime_type(mime_type)
    end

    def magnet_uri
      _, link = torrent_magnet_data
      link
    end

    def magnet_info_hash
      hash, _ = torrent_magnet_data
      hash
    end

    private

    def torrent_magnet_data
      [nil, nil]
    end

  end
end
