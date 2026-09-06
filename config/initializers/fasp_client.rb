# fasp_client's engine.rb references Linzer::Message::Adapter::Rack without
# requiring "linzer/rack", which defines it. Preload it here until fixed upstream.
# https://github.com/manyfold3d/fasp_client/blob/main/lib/fasp_client/engine.rb
require "linzer/rack"

FaspClient.configure do |conf|
  conf.authenticate = ->(request) do
    # Return a truthy value if the current user should be able to access and edit FASP providers, otherwise
    # return falsey. For example:
    #
    # Warden / Devise:
    # request.env["warden"]&.user&.is_administrator?
  end

  # Configure the layout name that should be used for views; defaults to "application"
  # conf.layout = "application"

  # For even tighter integration, you might want to use your own ApplicationController as the base
  # class for FaspClient controllers.
  # conf.controller_base = "::ApplicationController"
end
