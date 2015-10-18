require 'test_helper'

module Frontend
  class NewsControllerTest < ActionController::TestCase
    test "should get index" do
      create_list :news, 5
      get :index, format: :xml
      assert_response :success, format: :xml
    end
  end
end
