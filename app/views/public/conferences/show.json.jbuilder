json.cache! json_cached_key(:conference, @conference, @conference.events), expires_in: 10.minutes do
  json.partial! 'public/shared/conference', conference: @conference
  json.events Event.recorded_at(@conference), partial: 'public/shared/event', as: :event
end
