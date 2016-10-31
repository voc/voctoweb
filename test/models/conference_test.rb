require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase
  SCHEDULE_URL = 'http://sigint.ccc.de/schedule/schedule.xml'

  test 'should set initial state' do
    c = Conference.new
    assert c.not_present?
  end

  test 'should not save conference without acronym' do
    c = Conference.new
    assert_raises (ActiveRecord::RecordInvalid) { c.save! }
  end

  test 'should create conference' do
    conference = Conference.create(acronym: '123', schedule_url: SCHEDULE_URL)
    conference.save
    assert conference
  end

  test 'should download xml' do
    @conference = create(:conference_with_recordings)

    run_background_jobs_immediately do
      @conference.schedule_url = SCHEDULE_URL
    end
    assert @conference.downloaded?
    assert_not_nil @conference.schedule_xml
    assert @conference.schedule_xml.size > 0
  end

  test 'should get images url' do
    @conference = create(:conference_with_recordings)
    assert_equal "#{Settings.folders['images_webroot']}/#{@conference.images_path}", @conference.get_images_url_path
  end

  test 'should get logo url' do
    @conference = create(:conference, logo: 'test.png')
    assert_equal 'http://static.media.ccc.de/media/frabcon123/test.png', @conference.logo_url
  end

  test 'should return unknown logo if missing' do
    @conference = create(:conference, logo: nil)
    assert_equal 'http://static.media.ccc.de/media/unknown.png', @conference.logo_url
  end

  test 'should deny validation with invalid path' do
    @conference = create(:conference_with_recordings)

    @conference.recordings_path = '../../etc/passwd'
    refute @conference.save

    @conference.recordings_path = "\0/etc/passwd"
    assert_raises ArgumentError do
      @conference.save
    end
  end

  test 'should trim whitespace on paths' do
    recording = create(:conference, logo: ' logo.png ', images_path: ' to/the/images ', title: '  some  artistic   title ')
    assert recording.logo.strip == recording.logo
    assert recording.images_path.strip == recording.images_path

    refute recording.title.strip == recording.title
  end
end
