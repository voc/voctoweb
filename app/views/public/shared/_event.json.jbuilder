json.extract! event, :guid, :title, :subtitle, :slug, :link, :description, :original_language, :persons, :tags, :view_count, :promoted, :date, :release_date, :updated_at
json.length event.duration
json.duration event.duration
json.thumb_url event.get_thumb_url
json.poster_url event.get_poster_url
json.timeline_url event.get_timeline_url
json.thumbnails_url event.get_thumbnails_url
json.frontend_link frontend_event_url(slug: event.slug)
json.url public_event_url(id: event.guid, format: :json)
json.conference_title event.conference.title
json.conference_url public_conference_url(id: event.conference.acronym, format: :json)
json.related(event.related_events) do |related_event|
  json.event_id related_event.id
  json.event_guid related_event.guid
  json.weight event.metadata['related'][related_event.id.to_s]
end
