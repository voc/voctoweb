# Use the the official Ruby image as a base
FROM ruby:3.0-alpine

# Install runtime dependencies
# Node.js is used for JavaScript compression via the uglifier gem
RUN apk add --no-cache nodejs dumb-init curl git build-base libxml2-dev libxslt-dev postgresql-dev tzdata

WORKDIR /voctoweb

# Install required gems
ENV BUNDLE_FORCE_RUBY_PLATFORM 1
ENV BUNDLE_WITHOUT "development:test:doc"
COPY Gemfile Gemfile.lock /voctoweb/
RUN gem install -v 2.3.9 bundler && bundle install --jobs=4 && rm -fr ~/.bundle
