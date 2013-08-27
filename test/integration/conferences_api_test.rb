require 'test_helper'

class ConferencesApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = create(:api_key)
    @json = get_json
  end

  def get_json
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"conference":'
    d = '{"acronym":"frab666","recordings_path":"conference/frab123","images_path":"events/frab","webgen_location":"event/frab/frab123","aspect_ratio":"16:9","title":null,"schedule_url":"http://programm.froscon.org/2013/schedule.xml"}'
    json += d
    json+= '}'
    json
  end

  test "should create conference" do
    assert JSON.parse(@json)
    assert_difference('Conference.count') do
      post_json '/api/conferences.json', @json
    end
  end

end

