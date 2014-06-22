require 'test_helper'

class RecordingTest < ActiveSupport::TestCase

  setup do
    @recording = create(:recording)
    @event = @recording.event
  end

  test "should set initial state" do
    r = Recording.new
    assert r.new?
   end

  test "should not save without event" do
    r = Recording.new
    r.filename = "some.avi"
    assert_raises(ActiveRecord::RecordInvalid) { r.save! }
  end

  test "should not save without filename" do
    r = Recording.new
    r.event = @event
    assert_raises(ActiveRecord::RecordInvalid) { r.save! }
  end

  test "should save" do
    r = Recording.new
    r.event = @event
    r.filename = "some.avi"
    r.mime_type = 'video/webm'
    r.folder = ''
    assert_nothing_raised(ActiveRecord::RecordInvalid) { r.save! }
  end

  test "should download file" do
    path = create_test_file 'test.webm'
    @recording.mime_type = 'video/webm'
    @recording.original_url = "file://" + path
    @recording.state = 'new'
    @recording.save

    run_background_jobs_immediately do
      @recording.start_download
    end
    assert @recording.downloaded?
  end

end
