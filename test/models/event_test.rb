require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    @event = create(:event)
  end

  test "should count recordings" do
    @event.recordings << create(:recording, filename: 'video.webm', event: @event)
    @event.recordings << create(:recording, filename: 'video2.webm', event: @event)
    @event.reload
    assert_equal 2, @event.recordings.count
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

  test 'should trim whitespace on paths' do
    event = create(:event, poster_filename: ' poster.png ', thumb_filename: ' thump.jpeg ', timeline_filename: ' timeline.jpeg ', thumbnails_filename: ' thumbnails.vtt ', title: '  some  artistic   title ')
    assert_equal event.poster_filename, event.poster_filename.strip
    assert_equal event.thumb_filename, event.thumb_filename.strip
    assert_equal event.timeline_filename, event.timeline_filename.strip
    assert_equal event.thumbnails_filename, event.thumbnails_filename.strip
    refute_equal event.title, event.title.strip
  end

  test 'should initialize event_last_released_at to nil' do
    conference = create(:conference)
    assert_nil conference.event_last_released_at
  end

  test 'should update event_last_released_at when newer event with a release_date is added' do
    conference = create(:conference)
    assert_nil conference.event_last_released_at

    event1 = create(:event_with_recordings)
    event1.release_date = Time.new(2016, 01, 01)
    conference.events << event1

    assert_equal event1.release_date, conference.event_last_released_at


    # newer
    event2 = create(:event_with_recordings)
    event2.release_date = Time.new(2016, 01, 13)
    conference.events << event2

    # now event2
    assert_equal event2.release_date, conference.event_last_released_at


    # older
    event3 = create(:event_with_recordings)
    event3.release_date = Time.new(2015, 03, 01)
    conference.events << event3

    # still event2
    assert_equal event2.release_date, conference.event_last_released_at
  end

  test 'should update event_last_released_at when newer event is removed' do
    conference = create(:conference)
    assert_nil conference.event_last_released_at

    event1 = create(:event_with_recordings)
    event1.release_date = Time.new(2016, 01, 01)
    conference.events << event1

    # newer
    event2 = create(:event_with_recordings)
    event2.release_date = Time.new(2016, 01, 13)
    conference.events << event2

    # older
    event3 = create(:event_with_recordings)
    event3.release_date = Time.new(2015, 03, 01)
    conference.events << event3

    # unreleased event with only relive recording
    event4 = create(:event_with_recordings)
    event4.release_date = nil
    conference.events << event4

    # event2
    assert_equal event2.release_date, conference.event_last_released_at

    # still event2
    conference.events.delete(event3)
    assert_equal event2.release_date, conference.event_last_released_at

    # now event1
    conference.events.delete(event2)
    assert_equal event1.release_date, conference.event_last_released_at

    # now nil
    conference.events.delete(event1)
    assert_nil conference.event_last_released_at
  end

  test 'should update event_last_released_at when newer event is modified' do
    conference = create(:conference)
    assert_nil conference.event_last_released_at

    event1 = create(:event_with_recordings)
    event1.release_date = Time.new(2016, 01, 01)
    conference.events << event1

    # newer
    event2 = create(:event_with_recordings)
    event2.release_date = Time.new(2016, 01, 13)
    conference.events << event2

    # event2
    assert_equal event2.release_date, conference.event_last_released_at

    # move event2 into the past
    event2.release_date = Time.new(2014, 01, 01)
    event2.save()

    # now event1
    assert_equal event1.release_date, conference.event_last_released_at
  end


  test 'should not update event_last_released_at when unreleased event is added' do
    conference = create(:conference)
    assert_nil conference.event_last_released_at

    # unreleased event, maybe with relive recording
    event1 = create(:event_with_recordings)
    event1.release_date = nil
    conference.events << event1

    assert_nil conference.event_last_released_at
  end

  test 'should not update event_last_released_at when unreleased event is added, more complex' do
    conference = create(:conference)
    assert_nil conference.event_last_released_at

    # unreleased event, maybe with relive recording
    event1 = create(:event_with_recordings)
    event1.release_date = nil
    conference.events << event1

    assert_nil conference.event_last_released_at


    # normal event with rel
    event2 = create(:event_with_recordings)
    event2.release_date = Time.new(2016, 01, 13)
    conference.events << event2

    assert_equal conference.event_last_released_at, event2.release_date


    # unreleased event, maybe with relive recording
    event3 = create(:event_with_recordings)
    event3.release_date = nil
    conference.events << event3

    assert_equal conference.event_last_released_at, event2.release_date

  end


  test 'should trigger callback to update conferences event_last_released_at' do
    assert @event.conference
    assert_equal @event.conference.event_last_released_at, @event.release_date
    release_date = Time.now.since(2.days)
    @event.update(release_date: release_date)
    # compare timestamps to fix timezone comparison problems
    assert_equal release_date.to_i, @event.conference.event_last_released_at.to_i
  end

  test 'should resolve related_events from metadata' do
    e = create(:event)
    e.metadata = {'related': Hash[@event.id, 1] }
    e.save!

    assert_includes e.related_events, @event.becomes(Frontend::Event)
  end
end
