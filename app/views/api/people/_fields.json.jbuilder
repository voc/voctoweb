json.extract! person, :id, :name, :public_name, :email, :avatar_url, :description, :links
json.errors person.errors.to_a unless person.errors.attribute_names.length
