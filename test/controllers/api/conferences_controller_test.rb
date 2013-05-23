require 'test_helper'

class Api::ConferencesControllerTest < ActionController::TestCase

  setup do
    @key = api_keys(:one)
  end

  test "should list conferences" do
    get 'index', format: :json, api_key: @key.key
    assert_response :success
    assert JSON.parse(response.body)
  end

end
