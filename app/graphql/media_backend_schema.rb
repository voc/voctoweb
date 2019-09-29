class MediaBackendSchema < GraphQL::Schema
  max_depth 5
  query(Types::QueryType)
  #mutation(Types::MutationType)
end
