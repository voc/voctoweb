json.cache! json_cached_key(:conferences, @conferences), race_condition_ttl: 30 do
  json.conferences(@conferences) do |conference|
    json.partial! 'public/shared/conference', conference: conference
    json.url public_conference_url(conference.acronym, format: :json)
  end
end
