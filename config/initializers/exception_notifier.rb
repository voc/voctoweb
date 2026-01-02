if Rails.env.production? && ENV['NOTIFY_RECEIVER'].present?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    # See https://github.com/kmcphillips/exception_notification?tab=readme-ov-file#ignore-exceptions
    #ignore_exceptions: ['ActionView::TemplateError'] + ExceptionNotifier.ignored_exceptions,
    ignore_if: ->(env, exception) { exception.message =~ /^Invalid request parameters: Rack::Multipart::EmptyContentError/ },
    email: {
      email_prefix: '[MEDIA] ',
      sender_address: ENV['NOTIFY_SENDER'],
      exception_recipients: ENV['NOTIFY_RECEIVER'].split(/\s*,\s*/)
    }
end
