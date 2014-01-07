require 'test_helper'

class EventsApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = create(:api_key)
    @conference = create(:conference)
    @json = get_json
  end

  def get_json
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"guid":"12345",'
    json += '"slug":"12345",'
    json += '"acronym":"'
    json += @conference.acronym
    json += '",'
    json += '"poster_url":"http://koeln.ccc.de/images/chaosknoten_preview.jpg",'
    json += '"thumb_url":"http://koeln.ccc.de/images/chaosknoten.jpg",'
    json += '"gif_url":"http://koeln.ccc.de/images/chaosknoten.gif"'
    json+= '}'
    json
  end

  test "should create event" do
    assert JSON.parse(@json)
    assert_difference('Event.count') do
      post_json '/api/events.json', @json
    end
  end

end
