require 'test_helper'

class ImportTemplateTest < ActiveSupport::TestCase
  test "creates an import template" do
    assert_not_nil create :import_template
  end


  test "list recordings in storage" do
    it = create :import_template
    assert_not_nil it.recordings
  end
end
