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
    create_test_file 'test.mp3'
    @recording.original_url = "file://" + File.join(Rails.root, 'test.mp3')
    @recording.save

    run_background_jobs_immediately do
      @recording.start_download
    end
    assert @recording.released?
  end

  test "should save page file" do
    recording = create(:recording, state: :releasing)
    run_background_jobs_immediately do
      recording.release!
    end
    assert recording.released?
  end

end
