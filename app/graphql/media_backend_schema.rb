class MediaBackendSchema < GraphQL::Schema
  include ApolloFederation::Schema
  use ApolloFederation::Tracing

  max_depth 17
  query(Types::QueryType)
  #mutation(Types::MutationType)
end
