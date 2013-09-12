require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase

  SCHEDULE_URL = 'http://sigint.ccc.de/schedule/schedule.xml'

  setup do
    set_config_folders_to_tmp
  end

  test "should set initial state" do
    c = Conference.new
    assert c.not_present?
   end

  test "should not save conference without acronym" do
    c = Conference.new
    assert_raises (ActiveRecord::RecordInvalid) { c.save!  }
  end

  test "should create conference" do
    conference = Conference.create(acronym: "123", schedule_url: SCHEDULE_URL)
    conference.save
    assert conference
  end

  test "should download xml" do
    @conference = create(:conference_with_recordings)

    run_background_jobs_immediately do
      @conference.schedule_url = SCHEDULE_URL
    end
    assert @conference.downloaded?
    assert_not_nil @conference.schedule_xml
    assert @conference.schedule_xml.size > 0
  end

  test "should create videopage" do
    @conference = create(:conference_with_recordings)
    event = @conference.events.first
    VideopageBuilder.save_videopage(@conference, event)
    assert File.readable? event.get_videopage_path
  end

  test "should save podcast" do
    @conference = create(:conference_with_recordings)
    FileUtils.mkdir_p @conference.get_webgen_location

    @conference.events.each { |e|
      VideopageBuilder.save_videopage(@conference, e)
    }
    @conference.create_podcast
    assert File.readable? File.join(@conference.get_webgen_location, 'podcast.xml')
  end
  
end
