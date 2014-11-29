json.cache! json_cached_key(:event, @event, @event.recordings), expires_in: 10.minutes do
  json.partial! 'public/shared/event', event: @event
  json.recordings @event.recordings, partial: 'public/shared/recording', as: :recording
end
