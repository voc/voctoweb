require 'test_helper'

module Frontend
  class HomeControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
    test "should get about" do
      get :about
      assert_response :success
    end
  end
end
