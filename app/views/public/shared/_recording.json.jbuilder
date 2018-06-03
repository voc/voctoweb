json.extract! recording, :size, :length, :mime_type, :language, :filename, :state, :folder, :high_quality, :width, :height, :updated_at
json.recording_url recording.get_recording_url
json.url public_recording_url(recording, format: :json)
json.event_url public_event_url(id: recording.event.guid, format: :json)
json.conference_url public_conference_url(id: recording.conference.acronym, format: :json)
