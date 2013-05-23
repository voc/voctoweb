require 'test_helper'

class RecordingTest < ActiveSupport::TestCase

  setup do
    @event = Event.new(guid: '123')
    @recording = recordings(:one)
  end

  test "should set initial state" do
    r = Recording.new
    assert r.new?
   end

  test "should not save without event" do
    r = Recording.new
    r.filename = "some.avi"
    assert_raises(ActiveRecord::RecordInvalid) { r.save!  }
  end

  test "should not save without filename" do
    r = Recording.new
    r.event = @event
    assert_raises(ActiveRecord::RecordInvalid) { r.save!  }
  end

  test "should save" do
    r = Recording.new
    r.event = @event
    r.filename = "some.avi"
    assert_nothing_raised(ActiveRecord::RecordInvalid) { r.save!  }
  end

  test "should download file" do
    run_background_jobs_immediately do
      @recording.start_download
    end
    assert @recording.downloaded?
  end

end
