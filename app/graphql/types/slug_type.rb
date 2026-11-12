module Types
  class SlugType < GraphQL::Types::String
    description "A URL slug (no forward slashes)"
    graphql_name 'Slug'

    def self.coerce_input(input_value, _context)
      unless input_value.match?(/\A[^\/]+\z/)
        raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid slug"
      end

      input_value
    end

    def self.coerce_result(ruby_value, _context)
      ruby_value.to_s
    end
  end
end
