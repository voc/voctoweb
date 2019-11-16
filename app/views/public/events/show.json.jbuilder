json.cache! json_cached_key(:event, @event, @event.recordings), race_condition_ttl: 30 do
  json.partial! 'public/shared/event', event: @event
  json.recordings @event.recordings, partial: 'public/shared/recording', as: :recording
end
