json.cache! json_cached_key(:recording, @recording, @recording.event), race_condition_ttl: 30 do
  json.partial! 'public/shared/recording', recording: @recording
end
