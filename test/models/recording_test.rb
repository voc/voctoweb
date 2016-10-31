require 'test_helper'

class RecordingTest < ActiveSupport::TestCase
  setup do
    @recording = create(:recording)
    @event = @recording.event
  end

  test 'should not save without event' do
    r = Recording.new
    r.filename = 'some.avi'
    assert_raises(ActiveRecord::RecordInvalid) { r.save! }
  end

  test 'should not save without filename' do
    r = Recording.new
    r.event = @event
    assert_raises(ActiveRecord::RecordInvalid) { r.save! }
  end

  test 'should save' do
    r = Recording.new
    r.event = @event
    r.filename = 'some.avi'
    r.mime_type = 'video/webm'
    r.length = '10'
    r.width = 1
    r.height = 1
    r.folder = ''
    assert_nothing_raised { r.save! }
  end

  test 'should increase counter on event' do
    @event.recordings << create(:recording, filename: 'video2.webm', event: @event)
    @event.reload
    assert_equal 2, @event.downloaded_recordings_count
    @event.recordings.last.destroy
    @event.reload
    assert_equal 1, @event.downloaded_recordings_count
  end

  test 'should not save html5 recording with multiple languages' do
    @recording.language = 'eng-deu'
    @recording.html5 = true
    refute @recording.valid?
    @recording.html5 = false
    assert @recording.valid?
  end

  test 'should not save anything but subtitle with orig language' do
    @recording.language = 'orig'
    refute @recording.valid?
    @recording.mime_type = 'audio/mpeg'
    refute @recording.valid?
    @recording.mime_type = MimeType::SUBTITLE.first
    assert @recording.valid?
  end

  test 'should trim whitespace on paths' do
    recording = create(:recording, filename: ' video2.webm ', folder: ' fldr ', event: @event)
    assert recording.filename.strip == recording.filename
    assert recording.folder.strip == recording.folder
  end
end
