class MediaBackendSchema < GraphQL::Schema
  include ApolloFederation::Schema

  max_depth 13
  query(Types::QueryType)
  #mutation(Types::MutationType)
end
