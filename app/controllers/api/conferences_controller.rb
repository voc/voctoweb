class Api::ConferencesController < InheritedResources::Base
  before_filter :authenticate_api_key!
  protect_from_forgery :except => :create
  respond_to :json

  private

  def permitted_params
    {:conference => params.require(:conference).permit(:acronym, :schedule_url, :recordings_path, :images_path, :webgen_location, :aspect_ratio)}
  end
end
