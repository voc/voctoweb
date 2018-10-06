
module Types
  class ConferenceType < Types::BaseObject
    description "This entity is groups multiple lecutres together, e.g. a Confernece or Lecture Series"
    field :id, ID, null: false 
    field :title, String, null: false
    field :slug, String, null: false 
    field :lectures, [Types::LectureType], null: true

    #field :logo, Types::ImageType, null: true

    def id
      object.acronym
    end
    def lectures
      object.events
    end
  end
end