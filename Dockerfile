# Use the the official Ruby image as a base
FROM ruby:2.6-alpine

# Install runtime dependencies
# Node.js is used for JavaScript compression via the uglifier gem
RUN apk add --no-cache nodejs dumb-init curl git build-base libxml2-dev libxslt-dev postgresql-dev tzdata

WORKDIR /voctoweb

# Install required gems
COPY Gemfile Gemfile.lock /voctoweb/
RUN gem update --system && gem install -v 1.17.3 bundler && bundle install
