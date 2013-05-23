require 'test_helper'

class RecordingTest < ActiveSupport::TestCase

  setup do
    @event = Event.new(guid: '123')
  end

  test "should set initial state" do
    r = Recording.new
    assert r.new?
   end

  test "should not save without event" do
    r = Recording.new
    r.path = "/some"
    assert_raises(ActiveRecord::RecordInvalid) { r.save!  }
  end

  test "should not save without path" do
    r = Recording.new
    r.event = @event
    assert_raises(ActiveRecord::RecordInvalid) { r.save!  }
  end

  test "should save" do
    r = Recording.new
    r.event = @event
    r.path = "/some"
    assert_nothing_raised(ActiveRecord::RecordInvalid) { r.save!  }
  end
end
