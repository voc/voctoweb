module Frontend
  class HomeController < FrontendController
    def index
      @news = Frontend::News.recent(10)
      respond_to { |format| format.html }
    end

    def page_not_found
      respond_to do |format|
        format.html { render :page_not_found, status: 404 }
      end
    end
  end
end
