module Frontend
  class HomeController < FrontendController
    helper_method :recent_events_for_conference
    CONFERENCE_LIMIT = 9
    EVENT_LIMIT = 3

    def index
      @news = News.recent(1).first
      @hours_count = Event.sum(:duration)/(60*60)
      @recordings_count = Recording.count
      @events_count = Event.count
      @conferences_count = Conference.count

      @recent_conferences = Conference.with_recent_events(CONFERENCE_LIMIT)

      @currently_streaming = Conference.currently_streaming

      respond_to { |format| format.html }
    end

    def page_not_found
      respond_to do |format|
        format.json { head :no_content }
        format.xml { render xml: { status: :error } }
        format.all { render :page_not_found, status: 404, slug: params[:slug] }
      end
    end

    private

    def recent_events_for_conference(conference)
      conference.events.released.includes(:conference).limit(EVENT_LIMIT)
    end
  end
end
