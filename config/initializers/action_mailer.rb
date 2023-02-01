require 'settings'

MediaBackend::Application.configure do
  config.action_mailer.default_url_options = {
    host: Settings.frontend_host,
    protocol: Settings.frontend_proto,
  }
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_HOST'],
    enable_starttls_auto: false,
    ssl: false,
    tls: false
  }
end
