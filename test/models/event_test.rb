require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @event = events(:one)
  end

  test "should not save without a conference" do
    @event.conference = nil
    assert_raises (ActiveRecord::RecordInvalid) { @event.save!  }
  end
end
