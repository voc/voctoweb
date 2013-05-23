require 'test_helper'

class EventsApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = api_keys(:one)
    @conference = conferences(:two)
  end

  test "should create event" do
    # curl -H "CONTENT-TYPE: application/json" -d '{"api_key":"375cc0a5c6947b586800404b6921942e","acronym":"frab123","event":{"guid":"123"}}' "http://localhost:3000/api/events"
    
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"acronym":"'
    json += @conference.acronym
    json += '",'
    json += '"event":'
    d = '{"guid":"12345","gif_filename":"frab.gif","poster_filename":"test.png"}'
    json += d
    json+= '}'
    assert JSON.parse(json)

    assert_difference('Event.count') do
      post_json '/api/events.json', json
    end
  end

end
