json.array!(@people) do |person|
  json.partial! 'fields', person: person
  json.url api_person_url(person, format: :json)
end
