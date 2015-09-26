require 'test_helper'

module Frontend
  class ConferencesControllerTest < ActionController::TestCase
    test "should get index" do
      get :slug
      assert_response :success
    end

    test "should get index for slug" do
      get :slug, { slug: '123' }
      assert_response :success
    end
  end
end
