json.cache! json_cached_key(:conference, @conference, @conference.events), race_condition_ttl: 30 do
  json.partial! 'public/shared/conference', conference: @conference
  json.events Event.recorded_at(@conference), partial: 'public/shared/event', as: :event
end
