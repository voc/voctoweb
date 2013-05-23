require 'test_helper'

class ConferencesTest < ActionDispatch::IntegrationTest
  setup do
    @conference = conferences(:one)
  end

  test "should download xml" do
    @conference.schedule_url = 'http://sigint.ccc.de/schedule/schedule.xml'
    @conference.start_download
  end
  
  test "should add meta data" do
  end

  test "should  xml" do
  end
end

