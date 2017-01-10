if Rails.env.production? && ENV['NOTIFY_RECEIVER'].present?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    ignore_if: ->(env, exception) { exception.message =~ /^IP spoofing attack/ },
    email: {
      email_prefix: '[MEDIA] ',
      sender_address: ENV['NOTIFY_SENDER'],
      exception_recipients: ENV['NOTIFY_RECEIVER'].split(/\s*,\s*/)
    }
end
