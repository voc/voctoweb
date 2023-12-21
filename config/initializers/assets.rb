# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'images', 'frontend')
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'mediaelement')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'mediaelement-plugins')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'icomoon-font')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile = ["manifest.js"]

Rails.application.config.assets.precompile << ["*.svg", "*.eot", "*.woff", "*.ttf", "*.otf"] # [/\.(?:eot|otf|svg|ttf|woff|swf|svg|gif|png)/]

# for oembed layout
Rails.application.config.assets.precompile += %w[embed.css]

# players
Rails.application.config.assets.precompile += %w[oembed-player]
