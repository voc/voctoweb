class Frontend::HomeController < FrontendController
  layout 'frontend-index'

  def index
    @news = Frontend::News.recent(10)
  end
end
