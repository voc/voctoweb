json.extract! person, :id, :name, :public_name, :email, :avatar_url, :description
json.links person.links do |link|
  json.url  link.url
  json.name link.name if link.name.present?
  json.type link.link_type if link.link_type.present?
  json.service link.service if link.service.present?
end
json.errors person.errors.to_a unless person.errors.attribute_names.length
