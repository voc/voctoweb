require 'test_helper'

class ImportTemplateTest < ActiveSupport::TestCase

  test "creates an import template" do
    assert_not_nil create :import_template
  end

  test "list recordings in storage" do
    it = create :import_template

    FileUtils.mkdir_p File.join(it.get_recordings_path, it.folder)
    create_test_file "#{it.get_recordings_path}/webm/testevent.mp4"

    FileUtils.mkdir_p it.get_images_path
    create_test_file "#{it.get_images_path}/testevent.gif"

    assert_not_nil it.recordings
    assert it.recordings.count > 0
  end

end
