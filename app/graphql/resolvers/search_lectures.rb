class Resolvers::SearchLectures < GraphQL::Schema::Resolver
  type [Types::LectureType], null: false

  argument :query, String, required: true
  argument :page, Integer, required: false
  
  def resolve(query:, page: 1)
    results = Frontend::Event.query(query).page(page)
    @events = results.records.includes(recordings: :conference)
  end
end