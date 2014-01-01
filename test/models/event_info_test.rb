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

  test "should fill event info link from xml" do
    conference = create(:conference_with_recordings)
    event = conference.events.first
    event.guid = 'testGUID'
    event.conference.schedule_state = 'downloaded'
    event.fill_event_info
    assert event.event_info.present?
    assert_equal event.event_info.link, 'http://localhost/events/5060.html'
  end
end
