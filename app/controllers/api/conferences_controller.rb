class Api::ConferencesController < InheritedResources::Base
  before_filter :deny_json_request, if: :ssl_configured?
  before_filter :authenticate_api_key!
  protect_from_forgery except: %i(create)
  respond_to :json

  def create
    @conference = Conference.new(conference_params)

    respond_to do |format|
      if not @conference.schedule_url.nil? and @conference.valid? and @conference.validate_for_api and @conference.save
        @conference.url_changed!
        format.json { render json: @conference, status: :created }
      else
        Rails.logger.info("JSON: failed to create conference: #{@conference.errors.inspect}")
        format.json { render json: @conference.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def conference_params
    params.require(:conference).permit(:acronym, :schedule_url, :recordings_path, :images_path, :slug, :aspect_ratio)
  end

  def permitted_params
    {:conference => params.require(:conference).permit(:acronym, :schedule_url, :recordings_path, :images_path, :slug, :aspect_ratio)}
  end
end
