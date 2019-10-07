class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def deny_request
    render :file => 'public/403.html', :status => :forbidden, :layout => false
  end

  def deny_json_request
    render json: { errors: 'ssl required' }, :status => :forbidden
  end

  def ssl_configured?
    Rails.env.production? and not request.ssl?
  end

  def authenticate_api_key!
    if params['api_key']
      keys = ApiKey.find_by(key: params['api_key'])
    else
      authenticate_with_http_token do |token, options|
        keys = ApiKey.find_by(key: token)
      end
    end
    render json: { errors: 'No or invalid API key. Please add "Authorization: Token token=xxx" header or api_key=xxx param in URL or JSON request body.' }, :status => :forbidden if keys.nil?
  end

end
