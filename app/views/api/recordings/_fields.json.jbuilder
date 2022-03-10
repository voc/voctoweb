json.extract! recording, :id
json.public_url recording.url
json.errors recording.errors.to_a unless recording.errors.attribute_names.length
