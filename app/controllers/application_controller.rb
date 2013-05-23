class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def authenticate_api_key!
    keys = ApiKey.find_by key: params['api_key']
    redirect_to admin_dashboard_path if keys.nil?
  end

end
