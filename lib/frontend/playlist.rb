module Frontend
  class Playlist
    def self.for_conference(conference, lead_event: nil, audio: false)
      Playlist.new(conference.playlist(lead_event), conference: conference, audio: audio)
    end

    def self.related(event)
      Playlist.new(event.playlist)
    end

    def initialize(playlist, conference: nil, audio: false)
      @playlist_events = playlist
      @conference = conference
      @audio = audio
    end
    attr_reader :conference

    def playlist
      return audio_playlist if @audio
      video_playlist
    end

    def audio?
      @audio
    end

    def lead_event
      @playlist_events&.first
    end

    def poster_url
      lead_event.poster_url
    end

    def title
      return @conference.title if @conference
      lead_event.title
    end

    private

    def audio_playlist
      @playlist_events.select(&:audio_recording).map do |event|
        [event, event.audio_recording]
      end
    end

    def video_playlist
      @playlist_events.select(&:preferred_recording).map do |event|
        [event, event.preferred_recording]
      end
    end

  end
end
