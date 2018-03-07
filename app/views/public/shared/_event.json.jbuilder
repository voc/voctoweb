json.extract! event, :guid, :title, :subtitle, :slug, :link, :description, :original_language, :persons, :tags, :view_count, :promoted, :metadata, :date, :release_date, :updated_at
json.length event.duration
json.duration event.duration
json.thumb_url event.get_thumb_url
json.poster_url event.get_poster_url
json.frontend_link frontend_event_url(slug: event.slug)
json.url public_event_url(event, format: :json)
json.conference_url public_conference_url(event.conference, format: :json)
json.related(event.metadata['related']) do |id, weight|
  json.event_id id
  json.weight weight
end
