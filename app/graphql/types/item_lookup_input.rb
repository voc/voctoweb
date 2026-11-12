module Types
  class ItemLookupInput < Types::BaseInputObject
    description 'Lookup key for finding a single item. Provide exactly one of the fields below.'
    argument :guid, ID, required: false, description: "The item's guid"
    argument :slug, ID, required: false, description: "The item's URL slug"
  end
end
