if Rails.env.production? && ENV['NOTIFY_RECEIVER'].present?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[MEDIA] ',
      sender_address: ENV['NOTIFY_SENDER'],
      exception_recipients: ENV['NOTIFY_RECEIVER']
    }
end
