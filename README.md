# Ruby version

ruby 2.0.0

# System dependencies

Ubuntu

# Configuration

Application configuration is found in `config/initializers/media_backend.rb`

    recordings_base_dir: '/srv/recordings/cdn',
    images_base_dir: '/srv/www/cdn',
    webgen_base_dir: '/srv/www/webgen/src/browse',
    tmp_dir: '/tmp'

Configure folder names for mime type with `config.mime_type_folder_mappings`. The values of this hash will be used as actual folder names in the filesystem.

# Database creation

Setup your database in config/database.yml needed.    

    rake db:setup

# How to run the test suite

    rake test

# Services (job queues, cache servers, search engines, etc.)

    bin/delayed_job start

# Deployment instructions

You need to create a secret token for sessions:

    cp config/initializers/secret_token.rb.example config/initializers/secret_token.rb
    rake secret

To get the backend up and running:

    export RAILS_ENV=production 
    bundle install
    rake db:setup
    rake assets:precompile
    gem install passenger
    passenger start -p 8023

# First Login

Login as user `admin@example.org` with password `media123`. Change these values after the first login.


