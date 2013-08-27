require 'test_helper'

class Api::EventsControllerTest < ActionController::TestCase

  setup do
    @key = create(:api_key)
  end

  test "should list recent events" do
    get 'index', format: :json, api_key: @key.key
    assert_response :success
    assert JSON.parse(response.body)
  end

  test "should list events of conference" do
    get 'index', format: :json, api_key: @key.key, acronym: 'frabcon123'
    events = JSON.parse(response.body)
    assert events.size > 2
  end

end
