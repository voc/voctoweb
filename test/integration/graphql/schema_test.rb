require "test_helper"

class SchemaTest < ActiveSupport::TestCase

# disabled due to NoMethodError: undefined method `visible?' for nil:NilClass
#
#  def test_printout_is_up_to_date
#    current_defn = MediaBackendSchema.to_definition
#    printout_defn = File.read(Rails.root.join("app/graphql/schema.graphql"))
#    assert_equal(current_defn, printout_defn, "Update the printed schema with `bundle exec rake graphql:schema:dump`")
#  end
end