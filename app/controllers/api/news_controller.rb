class Api::NewsController < Api::BaseController
  protect_from_forgery :except => :create

  def news_params
    params.require(:news).permit(:date, :title, :body)
  end
end
