require "test_helper"

class SchemaTest < ActiveSupport::TestCase
  def test_printout_is_up_to_date
    current_defn = MediaBackendSchema.to_definition
    printout_defn = File.read(Rails.root.join("app/graphql/schema.graphql"))
    assert_equal(current_defn, printout_defn, "Update the printed schema with `bundle exec rake graphql:dump_schema`")
  end
end