json.cache! json_cached_key(:events, @events, @events.map(&:conference)), expires_in: 10.minutes do
  json.events(@events) do |event|
    json.partial! 'public/shared/event', event: event
    json.url public_event_url(event, format: :json)
  end
end
