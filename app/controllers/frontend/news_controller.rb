class Frontend::NewsController < FrontendController
  layout 'frontend-index'

  def index
    @news = News.all
  end
end
