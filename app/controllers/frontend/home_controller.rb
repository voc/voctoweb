module Frontend
  class HomeController < FrontendController
    def index
      @news = Frontend::News.recent(10)
    end
  end
end
