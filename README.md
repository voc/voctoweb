# media.ccc.de

media.ccc.de webfrontend, meta data editor and API.

[![Build Status](https://travis-ci.org/voc/media.ccc.de.svg?branch=master)](https://travis-ci.org/voc/media.ccc.de)
[![Code Climate](https://codeclimate.com/github/voc/media.ccc.de.png)](https://codeclimate.com/github/voc/media.ccc.de)

## Install

### Ruby Version

ruby 2.3.0

### Dependencies

* redis-server >= 2.8
* elasticsearch
* postgresql
* nodejs

### Quickstart / Development Notes

```
## for ubuntu 15.10
# install deps for ruby
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev libgdbm-dev libncurses5-dev automake libtool bison

# install deps for media.ccc.de
sudo apt-get install redis-server libpqxx-dev

# install node.js

    sudo apt-get install nodejs

# install rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer
\curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer.asc
gpg --verify rvm-installer.asc
bash rvm-installer stable
source ~/.rvm/scripts/rvm

# install ruby 2.3.0
rvm install ruby-2.3.0

# install bundler
gem install bundler

# postgresql setup
sudo -u postgres -i
createuser -d -P media

# obtaining & setting up media.ccc.de instance
git clone git@github.com:voc/media.ccc.de.git
cd media.ccc.de
bundle install
./bin/setup
rake db:migrate
rake db:fixtures:load


# run dev-server
rails server -b 0.0.0.0

# done
http://localhost:3000/ <- Frontend
http://localhost:3000/admin/ <- Backend
Backend-Login:
  Username: admin@example.org
  Password: media123
```

### Production Deployment Notes

Copy and edit the configuration file `config/settings.yml.template` to `config/settings.yml`.

You need to create a secret token for sessions, copy `env.example` to `.env.production` and edit.

#### Database Creation

Setup your database in config/database.yml needed.

    rake db:setup

#### Services (job queues, cache servers, search engines, etc.)

    sidekiq

#### Puma

```puma.rb
#!/usr/bin/env puma

directory '/srv/www/media-site/current'
rackup "/srv/www/media-site/current/config.ru"
environment 'production'

pidfile "/srv/www/media-site/shared/tmp/pids/puma.pid"
state_path "/srv/www/media-site/shared/tmp/pids/puma.state"
stdout_redirect '/srv/www/media-site/current/log/puma.error.log', '/srv/www/media-site/current/log/puma.access.log', true

threads 4,16

bind 'unix:///srv/www/media-site/shared/tmp/sockets/media-site-puma.sock'
bind 'tcp://127.0.0.1:3080'

workers 2

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "/srv/www/media-site/current/Gemfile"
end

before_fork do
  require 'rbtrace'
end
```

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
  * Available fields: https://github.com/voc/media.ccc.de/blob/master/db/schema.rb#L120-L135 
  * Required fields: https://github.com/voc/media.ccc.de/blob/master/app/models/recording.rb#L9-L13 
  * Allowed languages: https://github.com/voc/media.ccc.de/blob/master/lib/languages.rb
  * Example implementation: https://github.com/voc/publishing/blob/refactor/media_ccc_de_api_client.py#L291

```
    curl -H "CONTENT-TYPE: application/json" -d '{
        "api_key":"4",
        "guid":"123",
        "recording":{
          "filename":"some.mp4",
          "folder":"h264-hd",
          "mime_type":"video/mp4",
          "language":"deu"
          "size":"12",
          "length":"3600"
          }
      }' "http://localhost:3000/api/recordings"
```

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
