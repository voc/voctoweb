require 'test_helper'

class ConferencesTest < ActionDispatch::IntegrationTest

  setup do
    @key = api_keys(:one)
  end

  test "should create conference" do
    # curl -H "CONTENT-TYPE: application/json" -d '{"api_key":"375cc0a5c6947b586800404b6921942e","conference":{"acronym":"test"}}' "http://localhost:3000/api/conferences"
    
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"conference":'
    d = '{"acronym":"frab666","recordings_path":"conference/frab123","images_path":"events/frab","webgen_location":"event/frab/frab123","aspect_ratio":"16:9","title":null,"schedule_url":null}'
    json += d
    json+= '}'

    assert JSON.parse(json)
    assert_difference('Conference.count') do
      post '/api/conferences.json', json, "CONTENT_TYPE" => "application/json"
    end
  end

end

