json.array!(@conferences) do |conference|
  json.partial! 'fields', conference: conference
  json.url api_conference_url(conference, format: :json)
end
