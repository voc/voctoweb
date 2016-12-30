module Frontend
  class EventsController < FrontendController
    before_action :load_event

    def show
      respond_to { |format| format.html }
    end

    def postroll
      events = @conference.events.to_a
      pos = events.index(@event) + 1
      pos = 0 if pos >= events.count
      @new_event = events[pos]
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

    def load_event
      @event = Frontend::Event.find_by!(slug: params[:slug])
      @conference = @event.conference
    end
  end
end
