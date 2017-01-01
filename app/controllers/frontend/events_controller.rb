module Frontend
  class EventsController < FrontendController
    before_action :load_event

    def show
      respond_to { |format| format.html }
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
      return Event.find(@event.related_event_ids(n)) if @event.metadata[:related].present?
      @event.next_from_conference(n)
    end

    def load_event
      @event = Frontend::Event.find_by!(slug: params[:slug])
      @conference = @event.conference
    end
  end
end
