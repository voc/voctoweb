require 'test_helper'

class ConferenceImporterTest < ActiveSupport::TestCase

  test "imports an import template" do
    template = create :import_template

    assert_difference('Conference.count') do
      ConferenceImporter.import(template)
    end
  end

  test "imports partial template" do
    template = create :import_template, title: '', logo: ''
    assert_difference('Conference.count') do
      ConferenceImporter.import(template)
    end
  end

  test "imports template with files" do
    it = create :import_template, title: '', logo: ''
    FileUtils.mkdir_p File.join(it.get_recordings_path, it.folder)
    create_test_file "#{it.get_recordings_path}/webm/testevent.mp4"

    FileUtils.mkdir_p it.get_images_path
    create_test_file "#{it.get_images_path}/testevent.gif"

    assert_difference('Recording.count') do
      ConferenceImporter.import(it)
    end
    assert_equal 'testevent.gif', Event.last.thumb_filename
    assert_equal 'testevent.mp4', Recording.last.filename
  end

end
