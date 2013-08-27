require 'test_helper'

class RecordingsApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = create(:api_key)
    @event = create(:event)
    @json = get_json
  end

  def get_json
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"guid":"' + @event.guid + '",'
    json += '"recording":'
    d = '{"original_url":"file:///tmp/1","filename":"some.mp4","mime_type":"audio/mp4","size":"12","length":"30"}'
    json += d
    json+= '}'
    json
  end

  test "should create recording via json" do
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
