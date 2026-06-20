#!/bin/sh
export CAP_REPO=https://github.com/voc/voctoweb.git
export CAP_USER=media
export CAP_BRANCH=${1:-staging}
export SKIP_TAG=true

export CAP_HOST=app.media.test.c3voc.de
export CAP_PORT=22

#export MQTT_URL=mqtt://media:XXXXX@mng.c3voc.de

echo "Deploying branch ${CAP_BRANCH} to ${CAP_HOST}"

bundle exec cap staging deploy $*
