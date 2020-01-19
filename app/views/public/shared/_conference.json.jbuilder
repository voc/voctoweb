json.extract! conference, :acronym, :aspect_ratio, :updated_at, :title, :schedule_url, :slug, :event_last_released_at, :link, :description
json.webgen_location conference.slug
json.logo_url conference.logo_url
json.images_url conference.get_images_url
json.recordings_url conference.get_recordings_url
json.url public_conference_url(id: conference.acronym, format: :json)
