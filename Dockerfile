# Use the the official Ruby image as a base
FROM ruby:3.0-alpine

# Install runtime dependencies
# Node.js is used for JavaScript compression via the uglifier gem
RUN set -eux; \
	apk add --no-cache \
		dumb-init \
		nodejs \
		tzdata \
	;

WORKDIR /voctoweb

# Install required gems
ENV BUNDLE_FORCE_RUBY_PLATFORM 1
ENV BUNDLE_WITHOUT "development:test:doc"
ENV MAKEFLAGS "-j$(nproc)"
COPY Gemfile Gemfile.lock /voctoweb/
RUN set -eux; \
	apk add curl; \
	apk add --no-cache --virtual .build-deps \
		g++ \
		git \
		gcc \
		libxml2-dev \
		libxslt-dev \
		make \
		musl-dev \
		patch \
		postgresql-dev \
		build-base \
	; \
	\
	gem install -v 2.3.9 bundler; \
	bundle install --jobs=$(nproc); \
	rm -r ~/.bundle; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/bundle/gems \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .voctoweb-rundeps $runDeps; \
	apk del .build-deps
