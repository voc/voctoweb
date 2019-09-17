module Frontend
  class HomeController < FrontendController
    helper_method :recent_events_for_conference
    CONFERENCE_LIMIT = 3
    EVENT_LIMIT = 3

    def index
      @news = Frontend::News.recent(1).first
      @hours_count = Frontend::Event.sum(:duration)/(60*60)
      @recordings_count = Frontend::Recording.count
      @events_count = Frontend::Event.count
      @conferences_count = Frontend::Conference.count

      @recent_conferences = Frontend::Conference.with_recent_events(CONFERENCE_LIMIT)

      if Date.today == Date.parse("20.09.2019")
        @events = Frontend::Event.find([4889,7371,7594,7424,7423,7449,6272,7481,6567,7409].shuffle)
        render :template => 'frontend/home/index_klimastreik'
      else
        respond_to { |format| format.html }
      end
    end

    def page_not_found
      respond_to do |format|
        format.json { head :no_content }
        format.xml { render xml: { status: :error } }
        format.all { render :page_not_found, status: 404 }
      end
    end

    private

    def recent_events_for_conference(conference)
      conference.events.includes(:conference).limit(EVENT_LIMIT)
    end
  end
end
