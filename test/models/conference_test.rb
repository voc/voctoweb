require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase

  SCHEDULE_URL = 'http://sigint.ccc.de/schedule/schedule.xml'

  setup do
    @conference = conferences(:one)
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
    run_background_jobs_immediately do
      @conference.schedule_url = SCHEDULE_URL
    end
    assert @conference.downloaded?
    assert @conference.schedule_xml.size > 0
  end
  
end
