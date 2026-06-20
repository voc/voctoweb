class AdminUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ActiveAdmin::Devise::Controller

  def authentik
    @admin_user = AdminUser.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @admin_user, event: :authentication
  end

  def after_omniauth_failure_path_for(_scope)
    new_admin_user_session_path
  end
end
