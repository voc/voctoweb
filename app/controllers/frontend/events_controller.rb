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
      render layout: 'frontend/oembed'
    end

    private

    def load_event
      @event = event_from_params
      @conference = @event.conference
      @video_recordings = @event.recordings.video
      @audio_recordings = @event.recordings.audio
    end

    def event_from_params
      if params[:slug]
        Frontend::Event.find_by!(slug: params[:slug])
      else
        fail ActiveRecord::NotFound
      end
    end
  end
end
