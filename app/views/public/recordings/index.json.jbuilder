json.cache! json_cached_key(:recordings, @recordings.map(&:event), @recordings.map(&:conference)), race_condition_ttl: 30 do
  json.recordings(@recordings) do |recording|
    json.partial! 'public/shared/recording', recording: recording
    json.url public_recording_url(recording, format: :json)
  end
end
