source 'https://rubygems.org'

gem 'openssl'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0'
gem 'dotenv-rails'

gem 'activeadmin'
gem 'goldiloader'

gem 'devise'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'
gem 'aasm'
gem 'sidekiq'
gem 'foreman'
gem 'listen'

# rails cache
gem 'redis'
gem 'exception_notification'
gem 'connection_pool', '< 3'

# Bundle puma application server
gem 'puma'
gem 'puma_worker_killer'

group :development do
  gem 'bullet'
  gem 'capistrano', '~> 3.20.0', group: :capistrano, require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-sidekiq', require: false
  gem 'mqtt', :git => 'https://github.com/njh/ruby-mqtt.git'
  gem 'octokit',            require: false
  gem 'ed25519',            require: false
  gem 'bcrypt_pbkdf',       require: false
  gem 'solargraph',         require: false
  gem 'rbs',                require: false
end

gem 'haml'
gem 'redcarpet'
gem 'rss'

# kaminari must be listed before elasticsearch and api-pagination
gem 'kaminari'

gem 'pg', group: :postgresql

# needs to match server version
gem 'elasticsearch-model', '~> 8.0'
gem 'elasticsearch-rails', '~> 8.0'

# Asset pipeline: Propshaft (static) + jsbundling-rails/esbuild + cssbundling-rails/sass, managed via pnpm
gem 'propshaft'
gem 'jsbundling-rails'
gem 'cssbundling-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
gem 'yajl-ruby'

# Cross origin resource sharing for public json api and ajax clients
gem 'rack-cors', :require => 'rack/cors'

# FASP (Fediverse Auxiliary Service Provider) client
gem 'fasp_client'

# API pagination
gem 'api-pagination'

# GraphQL
gem 'graphql', '< 2'
gem 'graphql-query-resolver'
gem 'search_object'
gem 'search_object_graphql'
gem 'graphiql-rails'
gem 'apollo-federation'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
  gem 'ruby-graphviz', :require => 'graphviz' # Optional: only required for graphing
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :test do
  # minitest must match rails version
  gem 'minitest', '~> 5.1'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
end
