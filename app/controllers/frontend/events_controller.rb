module Frontend
  class EventsController < FrontendController
    before_action :load_event

    def show
      respond_to { |format| format.html }
    end

    def playlist_related
      @playlist = Playlist.related(@event)
      respond_to { |format| format.html { render :playlist } }
    end

    def playlist_conference
      @playlist = Playlist.for_conference(@conference, lead_event: @event)
      respond_to { |format| format.html { render :playlist } }
    end

    def audio_playlist_conference
      @playlist = Playlist.for_conference(@conference, lead_event: @event, audio: true)
      respond_to { |format| format.html { render :playlist } }
    end

    def postroll
      @events = related_events(3)
      render layout: false
    end

    # videoplayer suitable for embedding in an iframe
    def oembed
      @width = params[:width] || view_context.aspect_ratio_width
      @height = params[:height] || view_context.aspect_ratio_height
      response.headers.delete 'X-Frame-Options'
      render layout: 'frontend/oembed'
    end

    private

    def related_events(n)
      return Event.find(@event.related_event_ids(n)) if @event.metadata['related'].present?
      @event.next_from_conference(n)
    end

    def load_event
      @event = Frontend::Event.find_by!(
        "slug = ? OR guid = ? OR slug ILIKE ?", 
        params[:slug], params[:slug], params[:slug] + '%'
      )

      if params[:slug] != @event.slug
        redirect_to event_url(slug: @event.slug)
      end

      @conference = @event.conference
      @player = ''
      if params[:player] && /\A[a-z]+\Z/.match(params[:player])
        @player = '_' + params[:player]
      end
    end
  end
end
