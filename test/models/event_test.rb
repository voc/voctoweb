require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    @event = create(:event)
  end

  test "should not save without a conference" do
    @event.conference = nil
    assert_raises (ActiveRecord::RecordInvalid) { @event.save!  }
  end

  test "should fill info from xml" do
    assert_difference('Event.count') do
      event = build(:event)
      event.fill_event_info
      event.save!
    end
  end

  test "should save event with persons" do
    e = build(:event)
    e.subtitle = "subtitle"
    e.persons << "name1"
    e.persons << "name2"

    assert_difference 'Event.count' do
      e.save!
    end
  end

  test "should fill event link from xml" do
    conference = create(:conference_with_recordings)
    event = conference.events.first
    event.guid = 'testGUID'
    event.conference.schedule_state = 'downloaded'
    event.fill_event_info
    assert_equal event.link, 'http://localhost/events/5060.html'
  end

  test "should not touch conference if view count changed" do
    conference = create(:conference_with_recordings)
    event = conference.events.first
    old_updated_at = conference.reload.updated_at.to_i
    event.view_count = 123
    event.save!
    assert_equal old_updated_at, conference.reload.updated_at.to_i
  end
end
