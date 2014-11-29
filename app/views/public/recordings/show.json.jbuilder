json.cache! json_cached_key(:recording, @recording, @recording.event), expires_in: 10.minutes do
  json.partial! 'public/shared/recording', recording: @recording
end
