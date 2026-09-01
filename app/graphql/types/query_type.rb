module Types
  class QueryType < Types::BaseObject
    # add_field(GraphQL::Types::Relay::NodeField)
    # add_field(GraphQL::Types::Relay::NodesField)

    field :promoted, LectureType.connection_type, null: true, max_page_size: 30 do
      description 'Promoted lectures featured on the start page'
      argument :offset, Integer, default_value: 0, required: false, description: 'Offset for pagination'
    end
    def promoted(offset:, first: nil)
      Event.promoted(first || 10).offset(offset)
    end

    field :conference, ConferenceType, null: true do
      description 'Find a conference by acronym (e.g., `39c3`, `eh2010`)'
      argument :id, ID, required: true, description: 'The conference acronym'
    end
    def conference(id:)
      Conference.find_by(acronym: id)
    end

    field :conferences, resolver: Resolvers::Conference

    field :conferences_recent, [ConferenceType], null: true do
      description 'Recently active conferences with recorded events, ordered by most recent first'
      argument :first, Integer, default_value: 5, prepare: ->(limit, ctx) { [limit, 30].min }, required: true, description: 'Number of conferences to return (max 30)'
      argument :offset, Integer, default_value: 0, required: false, description: 'Offset for pagination'
    end
    def conferences_recent(offset:, first:)
      Conference.with_recent_events(first).offset(offset)
    end

    field :all_conferences, ConferenceType.connection_type, null: true do
      description 'All conferences with pagination support'
    end

    field :item, LectureType, null: true do
      description 'Find a single item by guid or slug'
      argument :by, Types::ItemLookupInput, required: true
    end
    def item(by:)
      if by.guid.present?
        Event.find_by(guid: by.guid)
      elsif by.slug.present?
        Event.find_by(slug: by.slug)
      else
        raise GraphQL::ExecutionError, 'ItemLookupInput requires either guid or slug'
      end
    end

    field :lecture, LectureType, null: true, deprecation_reason: 'Use `item(by: {guid: "<guid>"})` instead, which is a more generic name for the same query' do
      description 'Find a lecture by guid'
      argument :guid, ID, required: true
    end
    def lecture(guid:)
      Event.find_by(guid: guid)
    end

    field :lecture_by_slug, LectureType, null: true, deprecation_reason: 'Use `item(by: {slug: "slug>"})` instead, which is a more generic name for the same query' do
      description 'Find a lecture by slug'
      argument :slug, ID, required: true
    end
    def lecture_by_slug(slug:)
      Event.find_by(slug: slug)
    end

    field :lecture_search, resolver: Resolvers::SearchLectures

    field :lectures, resolver: Resolvers::Lectures, deprecation_reason: "Use items instead, which is a more generic name for the same query"
    field :items, resolver: Resolvers::Lectures

    field :lectures_related_to, LectureType.connection_type, null: true do
      description 'A list of related items'
      argument :guid, ID, required: true
    end
    def lectures_related_to(guid:)
      event = Event.find_by(guid: guid)
      event.related_events unless event.nil?
    end
  end
end
