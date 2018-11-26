
module Types
  class ConferenceType < Types::BaseObject
    description "This entity groups multiple lectures together, e.g. a Conference or Lecture Series"
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
