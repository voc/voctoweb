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
    assert_raises (ActiveRecord::RecordInvalid) { @event.save! }
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

  test 'videos_sorted_by_language should prioritize by original language and width (html5 is negligible)' do
    event = create(:event, original_language: 'eng')

    # Create recordings with different combinations of language, html5, and width
    # Scoring: (original_lang ? -5 : 0) + (html5 ? -2 : 0) - width
    # Since html5 bonus is only -2 and width is in hundreds/thousands, width dominates!
    # Expected order:
    # 1. eng + 1920: -5 + -2 - 1920 = -1927 (html5)
    # 2. eng + 1920: -5 + 0 - 1920 = -1925 (no html5, but same original lang + width)
    # 3. deu + 1920: 0 + -2 - 1920 = -1922
    # 4. eng + 1280: -5 + -2 - 1280 = -1287
    # 5. deu + 1280: 0 + 0 - 1280 = -1280

    rec1 = create(:recording, event: event, language: 'eng', html5: true, width: 1920, height: 1080, filename: 'eng_html5_1920.webm')
    rec2 = create(:recording, event: event, language: 'eng', html5: false, width: 1920, height: 1080, filename: 'eng_nohtml5_1920.webm')
    rec3 = create(:recording, event: event, language: 'deu', html5: true, width: 1920, height: 1080, filename: 'deu_html5_1920.webm')
    rec4 = create(:recording, event: event, language: 'eng', html5: true, width: 1280, height: 720, filename: 'eng_html5_1280.webm')
    rec5 = create(:recording, event: event, language: 'deu', html5: false, width: 1280, height: 720, filename: 'deu_nohtml5_1280.webm')

    sorted = event.videos_sorted_by_language

    # Verify the sorted order
    assert_equal 5, sorted.length
    assert_equal rec1, sorted[0], "Expected eng+html5+1920 to be first"
    assert_equal rec2, sorted[1], "Expected eng+nohtml5+1920 to be second (html5 bonus is tiny)"
    assert_equal rec3, sorted[2], "Expected deu+html5+1920 to be third"
    assert_equal rec4, sorted[3], "Expected eng+html5+1280 to be fourth"
    assert_equal rec5, sorted[4], "Expected deu+nohtml5+1280 to be fifth"
  end

  test 'videos_sorted_by_language should sort by mime_type first' do
    event = create(:event, original_language: 'eng')

    # Create recordings with different mime types
    rec_webm = create(:recording, event: event, mime_type: 'video/webm', width: 1920, filename: 'video.webm')
    rec_mp4 = create(:recording, event: event, mime_type: 'video/mp4', width: 1920, filename: 'video.mp4')

    sorted = event.videos_sorted_by_language

    # WebM should come before MP4 due to alphabetical mime_type sort
    assert_equal 2, sorted.length
    assert_equal 'video/mp4', sorted[0].mime_type
    assert_equal 'video/webm', sorted[1].mime_type
  end

  test 'videos_sorted_by_language should only include video recordings' do
    event = create(:event)

    # Create various recording types
    video = create(:recording, event: event, mime_type: 'video/webm', filename: 'video.webm')
    audio = create(:recording, event: event, mime_type: 'audio/mpeg', filename: 'audio.mp3')
    subtitle = create(:recording, event: event, mime_type: 'text/vtt', filename: 'subtitle.vtt', width: nil, height: nil, length: nil)

    sorted = event.videos_sorted_by_language

    # Should only include video recording
    assert_equal 1, sorted.length
    assert_equal video, sorted[0]
  end
end
