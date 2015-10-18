module Frontend
  class HomeController < FrontendController
    def index
      @news = Frontend::News.recent(10)
      respond_to { |format| format.html }
    end
  end
end
