require 'apollo-federation'

module Types
  class BaseField < GraphQL::Schema::Field
    include ApolloFederation::Field
  end
end
