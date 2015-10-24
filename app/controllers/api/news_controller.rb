class Api::NewsController < Api::BaseController
  protect_from_forgery :except => :create

  def permitted_params
    {:news => params.require(:news).permit(:date, :title, :body)}
  end
end
