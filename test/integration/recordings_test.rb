require 'test_helper'

class RecordingsTest < ActionDispatch::IntegrationTest

  setup do
    @key = api_keys(:one)
    @json = get_json
  end

  def get_json
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"guid":"testGUID",'
    json += '"recording":'
    d = '{"original_url":"file:///tmp/1","filename":"some.mp4","mime_type":"audio/mp4","size":"12","length":"30"}'
    json += d
    json+= '}'
    json
  end

  test "should create recording" do
    # curl -H "CONTENT-TYPE: application/json" -d '{"api_key":"375cc0a5c6947b586800404b6921942e","guid":"123","recording":{"original_url":"file:///tmp/1","filename":"some.mp4","mime_type":"audio/mp4","size":"12","length":"30"}}' "http://localhost:3000/api/recordings"
    
    assert JSON.parse(@json)
    assert_difference('Recording.count') do
      post_json '/api/recordings.json', @json
    end
  end

  test "should call start_download after create" do
    post_json '/api/recordings.json', @json
    event = Event.find_by guid: "testGUID"
    assert_not_nil event
    assert event.recordings.last.downloading?
  end

end
