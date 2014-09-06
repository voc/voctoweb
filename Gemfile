source 'https://rubygems.org'

gem 'activeadmin', github: 'activeadmin'
gem 'devise'
# act as state machine
gem 'state_machine', github: 'manno/state_machine'
gem 'delayed_job_active_record'
gem 'daemons'
gem "factory_girl_rails", "~> 4.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.0'

# Bundle puma application server
gem 'puma'

gem "dotenv-rails"

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Cross origin resource sharing for public json api and ajax clients
gem 'rack-cors', :require => 'rack/cors'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'pry-rails'
end

group :development do
  gem 'quiet_assets'
  gem 'ruby-graphviz', :require => 'graphviz' # Optional: only required for graphing
end

