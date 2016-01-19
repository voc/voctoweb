json.array!(@recordings) do |recording|
  json.partial! 'fields', recording: recording
  json.url api_recording_url(recording, format: :json)
end
