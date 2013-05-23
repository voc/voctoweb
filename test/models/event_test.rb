require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    @event = events(:one)
  end

  test "should not save without a conference" do
    @event.conference = nil
    assert_raises (ActiveRecord::RecordInvalid) { @event.save!  }
  end

  test "should fill info from xml" do
    assert_difference('EventInfo.count') do
      @event.fill_event_info
      @event.save!
    end
  end
end
