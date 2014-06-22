# media-backend 

media.ccc.de webfrontend meta data editor and API.

[![Build Status](https://travis-ci.org/cccc/media-backend.svg?branch=master)](https://travis-ci.org/cccc/media-backend)
[![Code Climate](https://codeclimate.com/github/cccc/media-backend.png)](https://codeclimate.com/github/cccc/media-backend)

## Install

### Ruby Version

ruby 2.0.0, 2.1.1

### Deployment Instructions

Copy and edit the configuration file `config/initializers/media_backend.rb.example` to `config/initializers/media_backend.rb`.

    recordings_base_dir: '/srv/recordings/cdn',
    images_base_dir: '/srv/www/cdn',
    webgen_base_dir: '/srv/www/webgen/src/browse',
    tmp_dir: '/tmp'

You need to create a secret token for sessions:

    cp config/initializers/secret_token.rb.example config/initializers/secret_token.rb
    rake secret

And another one for devise:    

    cp config/initializers/devise_secret_token.rb.example config/initializers/devise_secret_token.rb
    rake secret

### Database Creation

Setup your database in config/database.yml needed.

    rake db:setup

### Services (job queues, cache servers, search engines, etc.)

    bin/delayed_job start

### Start a Server

To get the backend up and running:

    export RAILS_ENV=production
    bundle install
    rake db:setup
    rake assets:precompile
    gem install passenger
    passenger start -p 8023

### Trigger nanoc

Nanoc is triggered via sudo

    Cmnd_Alias FRONTED = /srv/www/media-frontend/media-frontend/bin/frontend-wrapper
    media-backend ALL = (media-frontend) NOPASSWD: FRONTEND

## First Login

Login as user `admin@example.org` with password `media123`. Change these values after the first login.

## REST - API

All API calls need to use the JSON format.

Most REST operations work as expected. Examples for resource creation are listed on the applications dashboard page.

You can use the API to register a new conference. The conference `acronym` and the URL of the `schedule.xml` are required.
However folders and access rights need to be setup manually, before you can upload images and videos.

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
        "slug":"123",
        "poster_url":"http://koeln.ccc.de/images/chaosknoten_preview.jpg",
        "thumb_url":"http://koeln.ccc.de/images/chaosknoten.jpg",
        "gif_url":"http://koeln.ccc.de/images/chaosknoten.gif"
      }' "http://localhost:3000/api/events"

Recordings are added by specifiying the parent events `guid`, an URL and a `filename`.
The recording length is specified in seconds.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "guid":"123",
        "recording":{
          "original_url":"file:///tmp/123",
          "filename":"some.mp4",
          "folder":"mp4",
          "folder":"video/mp4",
          "size":"12",
          "length":"3600"
          }
      }' "http://localhost:3000/api/recordings"


Download event images again, after event was created.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "guid":"123",
        "poster_url":"http://koeln.ccc.de/images/chaosknoten_preview.jpg",
        "thumb_url":"http://koeln.ccc.de/images/chaosknoten.jpg",
        "gif_url":"http://koeln.ccc.de/images/chaosknoten.gif"
      }' "http://localhost:3000/api/events/download"

Download recordings again, after recording was created.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "guid":"123"
      }' "http://localhost:3000/api/recordings/download"


Create news items
      
    /api/news

Generate the site      

    /api/conferences/run_compile

Update promoted flag of events by view count    

    /api/events/update_promoted

## Public JSON API

    /public/conferences
    /public/conferences/:id
    /public/events
    /public/events/:id
    /public/recordings
    /public/recordings/:id
    /public/mirrors


Example:

    curl -H "CONTENT-TYPE: application/json" http://localhost:3000/public/conferences
