json.extract! recording, :size, :length, :mime_type, :filename, :original_url, :state, :folder, :width, :height, :updated_at
json.recording_url recording.get_recording_url
json.url public_recording_url(recording, format: :json)
json.event_url public_event_url(recording.event, format: :json)
json.conference_url public_conference_url(recording.conference, format: :json)
