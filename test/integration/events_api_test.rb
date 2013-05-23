require 'test_helper'

class EventsApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = api_keys(:one)
    @conference = conferences(:two)
    @json = get_json
  end

  def get_json
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"acronym":"'
    json += @conference.acronym
    json += '",'
    json += '"poster_url":"http://koeln.ccc.de/images/chaosknoten.gif",'
    json += '"gif_url":"http://koeln.ccc.de/images/chaosknoten.gif",'
    json += '"guid":"12345"'
    json+= '}'
    json
  end

  test "should create event" do
    # curl -H "CONTENT-TYPE: application/json" -d '{"api_key":"375cc0a5c6947b586800404b6921942e","acronym":"frab123","guid":"123"}' "http://localhost:3000/api/events"
    
    assert JSON.parse(@json)

    assert_difference('Event.count') do
      post_json '/api/events.json', @json
    end
  end

end
