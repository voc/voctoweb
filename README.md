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

The podcast feed template is in `config/podcast_template.yml` and needs to copied to 'podcast.yml'

# Database creation

Setup your database in config/database.yml needed.

    rake db:setup

# How to run the test suite

    rake test

# Services (job queues, cache servers, search engines, etc.)

    bin/delayed_job start

# Deployment instructions

Copy and edit the configuration file

  config/initializers/media_backend.rb.example

You need to create a secret token for sessions:

    cp config/initializers/secret_token.rb.example config/initializers/secret_token.rb
    rake secret

And for devise:    

    cp config/initializers/devise_secret_token.rb.example config/initializers/devise_secret_token.rb
    rake secret

To get the backend up and running:

    export RAILS_ENV=production
    bundle install
    rake db:setup
    rake assets:precompile
    gem install passenger
    passenger start -p 8023


## Trigger media-webgen

Webgen generation is triggered via sudo

    Cmnd_Alias WEBGEN = /srv/www/media-webgen/media-webgen/bin/webgen-wrapper
    media-backend ALL = (media-webgen) NOPASSWD: BACKUP


# First Login

Login as user `admin@example.org` with password `media123`. Change these values after the first login.

# REST - API

All API calls need to use the JSON format.

Most REST operations work as expected. Examples for resource creation are listed on the applications dashboard page.

You can use the API to register a new conference. The conference `acronym` and the URL of the `schedule.xml` are required.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4","acronym":"frab123",
        "recordings_path":"conference/frab123",
        "images_path":"events/frab",
        "webgen_location":"event/frab/frab123",
        "aspect_ratio":"16:9",
        "title":null,
        "schedule_url":"http://progam/schedule.xml"
      }' "http://localhost:3000/api/conferences"

You can add images to an event, like the animated gif thumb and the poster image. The event is identified by its `guid` and the conference `acronym`.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "acronym":"frab123",
        "guid":"123",
        "poster_url":"http://koeln.ccc.de/images/chaosknoten_preview.jpg",
        "thumb_url":"http://koeln.ccc.de/images/chaosknoten.jpg",
        "gif_url":"http://koeln.ccc.de/images/chaosknoten.gif"
      }' "http://localhost:3000/api/events"

Recordings are added by specifiying the parent events `guid`, an URL and a `filename`.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "guid":"123",
        "recording":{
          "original_url":"file:///tmp/123",
          "filename":"some.mp4",
          "mime_type":"video/mp4",
          "size":"12",
          "length":"30"
          }
      }' "http://localhost:3000/api/recordings"

Run webgen after uploads are finished.

    curl -H "CONTENT-TYPE: application/json" -d '{"api_key":"4"}' "http://localhost:3000/api/conferences/run_webgen"



