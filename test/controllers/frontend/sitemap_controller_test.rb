require 'test_helper'

module Frontend
  class SitemapControllerTest < ActionController::TestCase
    test "should get index" do
      get :index, format: :xml
      assert_response :success
    end
  end
end
