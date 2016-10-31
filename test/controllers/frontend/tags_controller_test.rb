require 'test_helper'

module Frontend
  class TagsControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get show for tag" do
      get :show, params: { tag: '123' }
      assert_response :success
    end
  end
end
