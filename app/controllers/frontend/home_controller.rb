module Frontend
  class HomeController < FrontendController
    def index
      @news = Frontend::News.recent(1).first()
      @events_count = Frontend::Event.count
      @conferences_count = Frontend::Conference.count


      respond_to { |format| format.html }
    end

    def page_not_found
      respond_to do |format|
        format.html { render :page_not_found, status: 404 }
      end
    end
  end
end
