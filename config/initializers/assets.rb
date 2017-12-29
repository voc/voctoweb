# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'images', 'frontend')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'mediaelement')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'mediaelement-plugins')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'icomoon-font')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += [/\.(?:eot|otf|svg|ttf|woff|swf|svg|gif|png)/]
Rails.application.config.assets.precompile += %w( mediaelement-and-player.js mediaelement-fix.js mirrorbrain-fix jquery mediaelementplayer embed.css )
