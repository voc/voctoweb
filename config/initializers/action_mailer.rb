MediaBackend::Application.configure do
  config.action_mailer.default_url_options = {
    host: ENV['APP_HOST'],
    protocol: ENV['APP_PROTO']
  }
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_HOST'],
    enable_starttls_auto: false,
    ssl: false,
    tls: false
  }
end
