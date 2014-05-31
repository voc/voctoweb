module MediaBackend
  class Application < Rails::Application
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '/public/*', :headers => :any, :methods => :get
      end
    end
  end
end
