class MediaBackendSchema < GraphQL::Schema
  include ApolloFederation::Schema
  use ApolloFederation::Tracing

  max_depth 17
  max_complexity 5000
  default_max_page_size 50
  query(Types::QueryType)
end
