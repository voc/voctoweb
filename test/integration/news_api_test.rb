require 'test_helper'

class NewsApiTest < ActionDispatch::IntegrationTest

  setup do
    @key = create(:api_key)
    @json = json_text
  end

  def json_text
    json = '{'
    json += '"api_key":"'
    json += @key.key
    json += '",'
    json += '"date":"2014-05-23",'
    json += '"title":"12345",'
    json += '"body":"text"'
    json += '}'
    json
  end

  test "should create event" do
    assert JSON.parse(@json)
    assert_difference('News.count') do
      post_json '/api/news.json', @json
    end
  end

end
