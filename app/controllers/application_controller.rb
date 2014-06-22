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
    keys = ApiKey.find_by key: params['api_key']
    redirect_to admin_dashboard_path if keys.nil?
  end

end
