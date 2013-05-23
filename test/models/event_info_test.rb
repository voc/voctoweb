require 'test_helper'

class EventInfoTest < ActiveSupport::TestCase
  test "should save event info" do
    e = EventInfo.new
    e.subtitle = "subtitle"
    e.persons << "name1"
    e.persons << "name2"

    assert_difference 'EventInfo.count' do
      e.save!
    end
  end
end
