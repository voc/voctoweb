module Frontend
  class EventsController < FrontendController
    before_action :load_event

    def show
      respond_to { |format| format.html }
    end

    # TODO obsolete action? old javascript fallback maybe? now probably defunct.
    def download
    end

    # videoplayer suitable for embedding in an iframe
    def oembed
      response.headers.delete 'X-Frame-Options'
      render layout: 'frontend/oembed'
    end

    private

    def load_event
      @event = Frontend::Event.find_by!(slug: params[:slug])
      @conference = @event.conference
      @video_recordings = @event.recordings.video
      @audio_recordings = @event.recordings.audio
      @subtitle_recording = @event.recordings.subtitle.first
    end
  end
end
