require 'test_helper'

class Public::MirrorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
  end
end
