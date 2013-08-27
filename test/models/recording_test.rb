require 'test_helper'

class RecordingTest < ActiveSupport::TestCase

  setup do
    @recording = create(:recording)
    @event = @recording.event
    @event_info = create(:event_info, event: @event)
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

  test "should download and release file" do
    MediaBackend::Application.config.folders[:recordings_base_dir] = '/tmp'
    run_background_jobs_immediately do
      @recording.start_download
    end
    assert @recording.released?
  end

  test "should save page file" do
    MediaBackend::Application.config.folders[:recordings_base_dir] = '/tmp'
    MediaBackend::Application.config.folders[:images_base_dir] = '/tmp'
    MediaBackend::Application.config.folders[:webgen_base_dir] = '/tmp'
    @event = create(:event)
    @event_info = create(:event_info)

    @event_info.event = @event
    @recording.event = @event
    @event.event_info = @event_info
    @event.recordings << @recording

    p @event.event_info
    p @event.recordings

    @recording.release!
    assert @recording.released?
  end

end
