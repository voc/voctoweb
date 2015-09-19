module Frontend
  class HomeController < FrontendController
    layout 'frontend/home'

    def index
      @news = Frontend::News.recent(10)
    end
  end
end
