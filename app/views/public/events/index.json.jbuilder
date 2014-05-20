json.array!(@events) do |event|
  json.partial! 'public/shared/event', event: event
  json.url public_event_url(event, format: :json)
end
