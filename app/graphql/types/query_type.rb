module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.


    field :conference, ConferenceType, null: true do
      description "Find a conference by acronym"
      argument :id, ID, required: true
    end
    def conference(id:)
      Conference.find_by(acronym: id)
    end

    field :allConferences, [ConferenceType], null: true do
      description "All conferences"
    end
    def all_conferences
      Conference.order('event_last_released_at DESC')
    end

    field :lecture, LectureType, null: true do
      description "Find a lecture by guid"
      argument :guid, ID, required: true
    end
    def lecture(guid:)
      Event.find_by(guid: guid)
    end

  end
end
