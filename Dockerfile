# Use the the official Ruby image as a base
FROM ruby:2.6.0

# Install runtime dependencies
# Node.js is used for JavaScript compression via the uglifier gem
RUN apt-get update -qq && apt-get install -y nodejs dumb-init

WORKDIR /voctoweb

# Install required gems
COPY Gemfile Gemfile.lock /voctoweb/
RUN gem update --system && gem install -v 1.17.3 bundler && bundle install
