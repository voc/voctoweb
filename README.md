# media.ccc.de

media.ccc.de webfrontend, meta data editor and API.

[![Build Status](https://travis-ci.org/voc/voctoweb.svg?branch=master)](https://travis-ci.org/voc/voctoweb)
[![Code Climate](https://codeclimate.com/github/voc/media.ccc.de.png)](https://codeclimate.com/github/voc/media.ccc.de)

## APIs

 Every talk (alias **event**, in other systems also called lecture or session) is assigned to exactly one **conference** (e.g. the _congress_ or lecture series like _datengarten_ or _openchaos_) and consists of multiple files alias **recordings**. These files can be video or audio recordings of the talk in different formats and languages (live-translation), subtitle tracks as srt or slides as pdf.

### Public JSON API

The public API provides a programatic access to the data behind media.ccc.de. Consumers of this API are typically player apps for different eco systems, see https://media.ccc.de/about.html#apps for a 'full' list. The whole API is "discoverable" starting from https://api.media.ccc.de/public/conferences ; Available methods:

    /public/conferences
    /public/conferences/:id
    /public/events
    /public/events/:id
    /public/events/search?q=:term'
    /public/recordings/:id
    /public/recordings

The id's are internal database ids, not to be confused with guids or conference talk ids (alias pentabarf/frab id), e.g. https://media.ccc.de/public/events/2935

Example:

    curl -H "CONTENT-TYPE: application/json" http://localhost:3000/public/conferences

The resulting JSON will contain URLs to each of the individual conferences.

Additionally the API for events and recordings uses RFC-5988 HTTP header based pagination to reduce the server load.

    curl -H "CONTENT-TYPE: application/json" "http://localhost:3000/public/events?page=10"

### Private REST API

The private API is used by our (video) production teams. They manage the content by adding new conferences, events and other files (so called recordings). All API calls need to use the JSON format. An example API client can be found as part of our publishing-script repository: https://github.com/voc/publishing/

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
  * other available methods: https://github.com/voc/media.ccc.de/blob/master/app/controllers/api/recordings_controller.rb
  * Available fields: https://github.com/voc/media.ccc.de/blob/master/db/schema.rb#L120-L135
  * Required fields: https://github.com/voc/media.ccc.de/blob/master/app/models/recording.rb#L9-L13
  * Allowed languages: https://github.com/voc/media.ccc.de/blob/master/lib/languages.rb
  * Example implementation: https://github.com/voc/publishing/

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


#### Setup Development-Server
```
# for ubuntu and debian one might want to install vagrant from upstream
# (https://www.vagrantup.com/downloads.html), because of a packaging bug:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=818237
$ sudo apt-get install vagrant virtualbox

$ vagrant plugin install vagrant-hostsupdater
$ vagrant up
$ vagrant ssh -c 'cd /vagrant && ./bin/update-data'

http://media.ccc.vm:3000/ <- Frontend
http://media.ccc.vm:3000/admin/ <- Backend
Backend-Login:
  Username: admin@example.org
  Password: media123
```

## Install for Production

### Ruby Version

ruby 2.4.1

### Dependencies

* redis-server >= 2.8
* elasticsearch
* postgresql
* nodejs

### Quickstart / Development Notes

```
## for ubuntu 15.10

# install deps for ruby
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev \
libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev \
python-software-properties libffi-dev libgdbm-dev libncurses5-dev automake libtool bison

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

# install ruby 2.4.1
rvm install ruby-2.4.1

# install bundler
gem install bundler

# postgresql setup
sudo -u postgres -i
createuser -d -P media

# obtaining & setting up a voctoweb instance
git clone git@github.com:voc/voctoweb.git
cd voctoweb
bundle install
./bin/setup
rake db:migrate
rake db:fixtures:load
```

### Run Development-Server manually

```
source ~/.rvm/scripts/rvm
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

#### Database Creation & Fixtures import

Setup your database in `config/database.yml` needed.

    rake db:setup
    ./bin/update-data

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
```

#### First Login

Login as user `admin@example.org` with password `media123`. Change these values after the first login.

