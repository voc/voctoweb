json.extract! event, :guid, :title, :subtitle, :slug, :link, :description, :persons, :tags, :date, :release_date, :updated_at
json.url public_event_url(event, format: :json)
