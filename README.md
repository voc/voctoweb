# media.ccc.de

media.ccc.de webfrontend, meta data editor and API.

[![Build Status](https://travis-ci.org/voc/media.ccc.de.svg?branch=master)](https://travis-ci.org/voc/media.ccc.de)
[![Code Climate](https://codeclimate.com/github/voc/media.ccc.de.png)](https://codeclimate.com/github/voc/media.ccc.de)

## Install

### Ruby Version

ruby 2.3.0

### Quickstart / Development

````
# install rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer
\curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer.asc
gpg --verify rvm-installer.asc
bash rvm-installer stable
source /home/peter/.rvm/scripts/rvm

# install ruby 2.3.0
rvm install ruby-2.3.0

# obtaining & setting up media.ccc.de instance
git clone git@github.com:voc/media.ccc.de.git
cd media.ccc.de
bundle install
./bin/setup
rake db:migrate
rake db:fixtures:load

# run dev-server
rails server

# done
http://localhost:3000/ <- Frontend
http://localhost:3000/admin/ <- Backend
Backend-Login:
  Username: admin@localhost.test
  Password: testadmin
````

### Production Deployment

Copy and edit the configuration file `config/settings.yml.template` to `config/settings.yml`.

    recordings_base_dir: '/srv/recordings/cdn',
    images_base_dir: '/srv/www/cdn',
    tmp_dir: '/tmp'

You need to create a secret token for sessions, copy `env.example` to `.env.production` and edit.

#### Database Creation

Setup your database in config/database.yml needed.

    rake db:setup

#### Services (job queues, cache servers, search engines, etc.)

    sidekiq

#### Start a Server

To get the backend up and running:

    export RAILS_ENV=production
    bundle install
    rake db:setup
    rake assets:precompile
    gem install passenger
    passenger start -p 8023

#### First Login

Login as user `admin@example.org` with password `media123`. Change these values after the first login.

## REST - API

All API calls need to use the JSON format.

Most REST operations work as expected. Examples for resource creation are listed on the applications dashboard page.

You can use the API to register a new conference. The conference `acronym` and the URL of the `schedule.xml` are required.
However folders and access rights need to be setup manually, before you can upload images and videos.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4","acronym":"frab123",
        "conference":{
          "recordings_path":"conference/frab123",
          "images_path":"events/frab",
          "slug":"event/frab/frab123",
          "aspect_ratio":"16:9",
          "title":null,
          "schedule_url":"http://progam/schedule.xml"
        }
      }' "http://localhost:3000/api/conferences"

You can add images to an event, like the poster image. The event is identified by its `guid` and the conference `acronym`.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "acronym":"frab123",
        "poster_url":"http://koeln.ccc.de/images/chaosknoten_preview.jpg",
        "thumb_url":"http://koeln.ccc.de/images/chaosknoten.jpg",
        "event":{
          "guid":"123",
          "slug":"123",
          "title":"qwerty"
        }
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
        "thumb_url":"http://koeln.ccc.de/images/chaosknoten.jpg"
      }' "http://localhost:3000/api/events/download"

Download recordings again, after recording was created.

    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "guid":"123"
      }' "http://localhost:3000/api/recordings/download"


Create news items

    /api/news

Update promoted flag of events by view count

    /api/events/update_promoted

Update view counts of events viewed in the last 30 minutes

    /api/events/update_view_counts

## Public JSON API

    /public/conferences
    /public/conferences/:id
    /public/events/:id
    /public/recordings/:id


Example:

    curl -H "CONTENT-TYPE: application/json" http://localhost:3000/public/conferences
