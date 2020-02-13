module GraphQL
  module Define
    class DefinedObjectProxy
      include Rails.application.routes.url_helpers
      Rails.application.routes.default_url_options[:host] = Settings.frontend_host
      Rails.application.routes.default_url_options[:protocol] = Settings.frontend_proto
    end
  end
end