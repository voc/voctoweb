class Api::BaseController < InheritedResources::Base
  before_filter :deny_json_request, if: :ssl_configured?
  before_filter :authenticate_api_key!
  respond_to :json
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found(error)
    format.json { render json: { message: 'not found', error: error.message }, status: :not_found }
  end

end
