require 'test_helper'

class ConferenceImporterTest < ActiveSupport::TestCase

  test "imports an import template" do
    template = create :import_template
    ConferenceImporter.import(template)
  end

end
