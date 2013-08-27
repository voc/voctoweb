require 'test_helper'

class Api::RecordingsControllerTest < ActionController::TestCase

  setup do
    @key = create(:api_key)
  end

  test "should list recent recordings" do
    get 'index', format: :json, api_key: @key.key
    assert_response :success
    assert JSON.parse(response.body)
  end
end
