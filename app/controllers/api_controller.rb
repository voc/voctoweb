class ApiController < ApplicationController
  include ApiErrorResponses
  before_filter :deny_json_request, if: :ssl_configured?
  before_filter :authenticate_api_key!
  respond_to :json
end
