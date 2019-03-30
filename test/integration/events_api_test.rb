require 'test_helper'

class EventsApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = create(:api_key)
    @conference = create(:conference)
    @json = json_text
  end

  def json_text
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"guid":"12345",'
    json += '"slug":"12345",'
    json += '"link":"http://link.to",'
    json += '"original_language":"eng-deu",'
    json += '"title":"title1",'
    json += '"persons":["a","b","c"],'
    json += '"acronym":"'
    json += @conference.acronym
    json += '",'
    json += '"poster_url":"http://koeln.ccc.de/images/chaosknoten_preview.jpg",'
    json += '"thumb_url":"http://koeln.ccc.de/images/chaosknoten.jpg",'
    json += '"timeline_url":"http://koeln.ccc.de/images/chaosknoten.timeline.jpg",'
    json += '"thumbnails_url":"http://koeln.ccc.de/images/chaosknoten.thumbnails.vtt"'
    json+= '}'
    json
  end

  test "should create event" do
    assert JSON.parse(@json)

    assert_difference('Event.count') do
      post_json '/api/events.json', @json
    end

    event = Event.where(guid: '12345').first
    assert_equal 'http://link.to', event.link
    assert_equal 'chaosknoten.jpg', event.thumb_filename
    assert_equal %w[a b c], event.persons
  end
end
