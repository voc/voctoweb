require 'test_helper'

module Frontend
  class NewsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  end
end
