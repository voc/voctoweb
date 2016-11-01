class ApiController < ApplicationController
  include ApiErrorResponses
  before_action :deny_json_request, if: :ssl_configured?
  before_action :authenticate_api_key!
  respond_to :json
end
