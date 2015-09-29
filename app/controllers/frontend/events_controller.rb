module Frontend
  class EventsController < FrontendController
    before_action :load_event
    def show
    end

    def download
    end

    def oembed
      # render layout: 'frontend/oembed'
    end

    private

    def load_event
      params[:slug] = '' if params[:slug] == 'index'
      @event = Frontend::Event.by_identifier(params[:conference_slug], params[:slug])
      @conference = @event.conference
      @video_recordings = []
      @audio_recordings = []
    end
  end
end
