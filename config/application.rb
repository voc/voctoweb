require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Rails.load

module MediaBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'Berlin'

    config.eager_load_paths << Rails.root.join('lib')

    # use custom error pages
    config.exceptions_app = self.routes

    config.app_generators.scaffold_controller = :scaffold_controller

    config.custom_css = nil

    # Extra asset roots (bare-filename resolution, matching the old Sprockets
    # config.assets.paths setup). Must be set here, not in config/initializers,
    # since Propshaft builds its asset assembly from a snapshot of this config
    # before user initializers run.
    config.assets.paths << Rails.root.join('app', 'assets', 'images', 'frontend')
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'mediaelement')
    # NB: cannot be named starting with "mediaelement" - Propshaft::LoadPath#dedup
    # does a naive string prefix check and would silently drop it as a duplicate
    # of the vendor/assets/mediaelement path registered above.
    config.assets.paths << Rails.root.join('vendor', 'assets', 'player-plugins')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'icomoon-font')
  end
end
