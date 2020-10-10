json.events(@events) do |event|
  json.partial! 'public/shared/event', event: event
  json.partial! 'public/shared/event_recordings', recordings: event.recordings
  json.url public_event_url(event.guid, format: :json)
end
