class Api::NewsController < InheritedResources::Base
  before_filter :authenticate_api_key!
  protect_from_forgery :except => :create
  respond_to :json
  def permitted_params
    {:news => params.require(:news).permit(:date, :title, :body)}
  end
end
