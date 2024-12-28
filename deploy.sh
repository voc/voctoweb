#!/bin/sh

export CAP_REPO=https://github.com/voc/voctoweb.git
export CAP_BRANCH=main
export CAP_USER=media

export CAP_HOST=app.media.ccc.de
export CAP_PORT=22

bundle exec cap production deploy
