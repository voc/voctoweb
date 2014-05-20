json.extract! conference, :acronym, :aspect_ratio, :updated_at, :title, :schedule_url
json.logo_url conference.get_logo_url
json.images_url conference.get_images_url
json.recordings_url conference.get_recordings_url
