module Frontend
  class HomeController < FrontendController
    helper_method :recent_events_for_conference

    def index
      @news = Frontend::News.recent(1).first()
      @hours_count = Frontend::Event.sum(:duration)/(60*60)
      @recordings_count = Frontend::Recording.count
      @events_count = Frontend::Event.count
      @conferences_count = Frontend::Conference.count

      @conference_limit = 3
      @events_limit = 3

      @recent_conferences = Frontend::Conference.with_recent_events().limit(@conference_limit)

      respond_to { |format| format.html }
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
      conference.events.order('release_date DESC, id DESC').limit(@events_limit)
    end
  end
end
