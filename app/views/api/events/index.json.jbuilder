json.array!(@events) do |event|
  json.partial! 'fields', event: event
  json.url api_event_url(event, format: :json)
end
