# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Voctoweb is a Rails 7.2 web app serving as a "YouTube-like" interface for the C3VOC (Chaos Computer Club Video Operation Center) media archive — conferences, talks, recordings. Live at media.ccc.de.

- **Ruby 3.4**, Rails 7.2.2, PostgreSQL, Redis, Elasticsearch 6.8.x, Sidekiq

## Development Setup

Docker is preferred:
```bash
bin/docker-dev-up        # Start all services (app, sidekiq, postgres, elasticsearch, redis, nginx)
```

Manual setup requires copying config templates first:
```bash
cp config/settings.yml.template config/settings.yml
cp config/database.yml.template config/database.yml
bin/setup                # Installs gems, prepares database
rails server -b 0.0.0.0  # http://localhost:3000
```

Admin panel: http://localhost:3000/admin (default: admin@example.org / media123)

## Commands

```bash
bundle exec rake              # Run all tests
bundle exec rubocop           # Lint
rake db:migrate               # Run pending migrations
rake db:setup                 # Create + migrate + seed
bin/update-data               # Download and load public data dump
```

Run a single test file:
```bash
bundle exec ruby -Itest test/models/event_test.rb
```

## Architecture

**Data model:**
- `Conference` → has many `Event`s → has many `Recording`s
- `Event` has many `Participant`s (speakers) via `Person`
- `Recording` represents media files (video, audio, PDFs, subtitles) with MIME types and URLs

**Three APIs exposed:**
1. **Public REST** — `/public/conferences`, `/public/events`, `/public/recordings` (paginated JSON)
2. **Private REST** — `/api/*` (token-auth, for production teams uploading recordings)
3. **GraphQL** — `/graphql` (Apollo Federation, used by media.ccc.de frontend)

**Key directories:**
- `app/admin/` — ActiveAdmin dashboards (bulk of the admin UI)
- `app/controllers/api/` — Private REST API
- `app/controllers/frontend/` — Public web UI controllers
- `app/graphql/` — GraphQL schema, types, mutations, resolvers
- `app/workers/` — Sidekiq background jobs
- `lib/feeds/` — Podcast/RSS feed generators

**Config:**
- `config/settings.yml` — App-level settings (API tokens, feature flags); template at `config/settings.yml.template`
- `config/routes.rb` — Namespaced: `api`, `public`, `graphql`, `frontend`

## Testing

Tests use Minitest + Factory Bot. The CI pipeline (`.github/workflows/ci.yml`) runs against PostgreSQL 12, Redis, and Elasticsearch 6.8.17.

No fixtures for most models — use factories in `test/factories/`.

## Linting

RuboCop config in `.rubocop.yml` targets Ruby 3.1+. Line length limit is 1024 (intentionally permissive). Many existing offenses are suppressed in `.rubocop_todo.yml` — don't add new entries there without good reason.
