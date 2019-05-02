
# This entity is an Event with multiple Files e.g. Video and Audio recordings, as well as PDFs e.g. the lecture slides
# alternate Name: Lecture, Talk?
module Types
  class LectureType < Types::BaseObject
    description "This entity is an Event with multiple Files e.g. Video and Audio recordings, as well as PDFs e.g. the lecture slides"
    field :guid, ID, null: false 
    field :localId, Integer, null: false
    #field :conference, Types::ConferenceType, null: false

    field :title, String, null: false
    field :slug, String, null: false
    field :release_date, GraphQL::Types::ISO8601DateTime, null: false
    field :original_language, String, null: false # TODO enum

    field :assets, [Types::AssetType], null: false

    #field :thumbnail, Types::ImageType, null: true

    def local_id
      object.id
    end

    def assets
      object.recordings
    end

  end
end