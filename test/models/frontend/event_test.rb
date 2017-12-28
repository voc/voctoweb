require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    @event = create(:event)
  end

  test "should return first slide by order of mime types" do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'audio.ogg', event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', folder: 'slides', filename: 'slides.mp4', event: @event)
    @event.recordings << create(:recording, mime_type: 'application/pdf', folder: 'slides', filename: 'slides.pdf', event: @event)
    @event = Frontend::Event.find(@event.id)
    assert_equal 'slides.pdf', @event.slide.filename
  end

  test "should find preferred recordings" do
    @event.recordings << create(:recording, mime_type: 'audio/mpeg', filename: 'audio.mp3', event: @event)
    @event.recordings << create(:recording, mime_type: 'audio/ogg', filename: 'audio.ogg', event: @event)
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'video.mp4', event: @event)
    @event = Frontend::Event.find(@event.id)
    assert_equal 'audio.ogg', @event.audio_recording.filename
    assert_equal 'video.mp4', @event.preferred_recording.filename
  end

  test "should not find preferred recordings" do
    @event.recordings << create(:recording, mime_type: 'video/mp4', filename: 'video.mp4', event: @event)
    @event = Frontend::Event.find(@event.id)
    assert_nil @event.audio_recording
  end

  test 'should list related events' do
    events = create_list(:event, 3)
    @event.metadata[:related] = events.pluck(:id).each_with_object({}) { |v,h| h[v] = 1 }
    @event.save
    assert_equal 3, @event.metadata['related'].count
  end

  test 'should shorten titles using ellipsis character' do
    @event = Frontend::Event.new
    @event.title = "regular title"
    assert_equal "regular title", @event.short_title

    @event.title = "too long title.....20...25...30...35...40....45"
    assert_equal "too long title.....20...25...30...35...…", @event.short_title
  end
end
