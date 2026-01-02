# Frontend Models

This directory contains **presentation-layer models** that extend the base domain models with frontend-specific logic.
They are used from the frontend controllers.

## Architecture Pattern

Frontend models inherit from base models and add presentation logic for the public-facing website:

```ruby
# Base model - handles persistence and business logic
class Event < ApplicationRecord
  # validations, callbacks, core domain logic
end

# Frontend model - adds presentation logic
module Frontend
  class Event < ::Event
    # presentation helpers, frontend scopes, view-specific methods
  end
end
```

## When to Use Which Model

### Use Base Models (`Event`, `Conference`, `Recording`) in:

- **API Controllers** (`app/controllers/api/`, `app/controllers/public/`)
- **Admin Controllers** (`app/admin/`)
- **Background Workers** (`app/workers/`)
- **Base Models** (never call Frontend:: methods here!)
- **Rake Tasks** (`lib/tasks/`)
- **GraphQL Types** (`app/graphql/`)

### Use Frontend Models (`Frontend::Event`, etc.) in:

- **Frontend Controllers** (`app/controllers/frontend/`)
- **Frontend Views** (`app/views/frontend/`)
- **Frontend Helpers** (when working with presentation logic)

## Critical Rule: No Frontend Models in Base Models

**❌ NEVER do this:**

```ruby
# In app/models/event.rb
class Event < ApplicationRecord
  def new_related_events
    # ERROR! Base models cannot reference Frontend:: methods
    related_events
  end
end

# In app/models/frontend/event.rb
module Frontend
  class Event < ::Event
    def related_events
      Event.where(id: related_ids)
    end
  end
end
```

## What Frontend Models Add

### Frontend::Event
- Presentation helpers: `short_title`, `short_description`, `display_date`
- URL builders: `poster_url`, `thumb_url`, `timeline_url`
- Download logic: `videos_for_download`, `audio_recordings_for_download`
- Player integration: `clappr_sources`, `clappr_subtitles`
- Frontend scopes: `promoted`, `popular`, `unpopular`

### Frontend::Conference
- Frontend scopes: `with_recent_events`, `currently_streaming`
- Streaming helpers: `live`, `has_live?`, `first_live`
- MIME type helpers: `mime_types`, `mime_type_names`
- Playlist building: `playlist(event)`

### Frontend::Recording
- Resolution helper: `resolution` (sd, hd, full-hd, 4k)
- MIME type scoping: `by_mime_type(mime_type)`

## Association Overrides

Frontend models override associations to return other Frontend:: models:

```ruby
module Frontend
  class Event < ::Event
    belongs_to :conference, class_name: 'Frontend::Conference'
    has_many :recordings, class_name: 'Frontend::Recording'
  end
end
```

This ensures when you load `@event.conference` from a Frontend::Event, you get a Frontend::Conference with all its presentation helpers.

## Common Mistakes

1. **Using Frontend:: in workers** - Workers should use base models
2. **Using Frontend:: in API** - API consumers don't need presentation helpers
3. **Calling Frontend:: methods from base models** - Those methods won't exist when using the base model
4. **Mixing Frontend:: and base models** - Stick to one per context

## When in Doubt

Ask yourself: "Is this for rendering the public website?"
- **Yes** → Use `Frontend::` models
- **No** → Use base models

The frontend is just one consumer of your domain models. APIs, admin, and background jobs are other consumers that don't need presentation logic.

## Trade-offs of Pattern

### Benefits:
- Clear separation: API uses Event, frontend uses Frontend::Event
- All ActiveRecord features work (associations, scopes, validations)
- No need for unwrapping/wrapping like decorators
- Frontend-specific Elasticsearch configuration

### Drawbacks:
- Non-standard pattern - new developers might be confused
- Inheritance can be tricky (method resolution order)
- Some duplication in association declarations
- Could lead to "which model do I use?" questions
