class Api::ConferencesController < Api::BaseController
  protect_from_forgery except: %i(create)

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
end
