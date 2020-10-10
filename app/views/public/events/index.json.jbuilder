json.cache! json_cached_key(:events, @events, @events.map(&:conference)), race_condition_ttl: 30 do
  json.events(@events) do |event|
    json.partial! 'public/shared/event', event: event
    json.url public_event_url(event.guid, format: :json)
  end
end
