module Types
  class JsonType < GraphQL::Types::String
    description "A untyped JSON document"
    graphql_name 'JSON'
  
    def self.coerce_input(input_value, context)
      # TODO check if input_value is already pared or not
      data = JSON.parse(input_value)
      if data.nil?
        raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid JSON"
      end
      # It's valid, return the URI object
      data
    end
  
    def self.coerce_result(ruby_value, context)
      ruby_value
    end
  end
end