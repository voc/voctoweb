module Frontend
  class Playlist

    def self.for_conference(conference, event = nil)
      Playlist.new(conference.playlist(event), conference: conference)
    end

    def self.related(event)
      Playlist.new(event.playlist)
    end

    def initialize(playlist, conference: nil)
      @playlist = playlist
      @conference = conference
    end
    attr_reader :playlist, :conference

    def video?
      @playlist.any? { |e| e.recordings.video.present? }
    end

    def poster_url
      lead_event.poster_url
    end

    def lead_event
      @playlist&.first
    end

    def title
      return @conference.title if @conference
      lead_event.title
    end
  end
end
