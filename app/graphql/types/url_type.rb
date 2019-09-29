module Types
  class Types::UrlType < Types::BaseObject
    description "A valid URL, transported as a string"
    graphql_name 'URL'
  
    def self.coerce_input(input_value, context)
      # Parse the incoming object into a `URI`
      url = URI.parse(input_value)
      if url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
        # It's valid, return the URI object
        url
      else
        raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid URL"
      end
    end
  
    def self.coerce_result(ruby_value, context)
      # It's transported as a string, so stringify it
      ruby_value.to_s
    end
  end
end