json.recordings(recordings) do |recording|
  json.partial! 'public/shared/recording', recording: recording
  json.url public_recording_url(recording, format: :json)
end
