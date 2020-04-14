module Types
  class BaseObject < GraphQL::Schema::Object
    include ApolloFederation::Object

    field_class BaseField
  end
end
