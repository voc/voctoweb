json.array!(@conferences) do |conference|
  json.partial! 'public/shared/conference', conference: conference
  json.url public_conference_url(conference, format: :json)
end
