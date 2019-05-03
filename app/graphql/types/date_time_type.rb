module Types
  class DateTimeType < Types::BaseScalar
    graphql_name 'DateTime'
  
    def self.coerce_input(input_value, context)
      Time.zone.parse(input_value)
    end
  
    def self.coerce_result(ruby_value, context)
      ruby_value.value.utc.iso8601
    end
  end
end
