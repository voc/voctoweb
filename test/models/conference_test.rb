require 'test_helper'

class ConferenceTest < ActiveSupport::TestCase

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

  def add_schedule_url(conference)
    conference.schedule_url = 'http://sigint.ccc.de/schedule/schedule.xml'
    conference.url_changed
    conference
  end

  test "should set state to downloading" do
    add_schedule_url(@conference)
    @conference.start_download
    # async jobs won't get executed
    assert @conference.downloading?
  end

  test "should set state to finished" do
    add_schedule_url(@conference)
    @conference.schedule_state = :downloading
    @conference.finish_download
    assert @conference.downloaded?
  end

  test "should download xml" do
    add_schedule_url(@conference)
    run_background_jobs_immediately do
      @conference.start_download
    end
    assert @conference.downloaded?
    assert @conference.schedule_xml.size > 0
  end
  
end
