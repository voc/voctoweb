module Types
  class BaseObject < GraphQL::Schema::Object
    include ApolloFederation::Object

    field_class BaseField
    connection_type_class(BaseConnection)
  end
end
