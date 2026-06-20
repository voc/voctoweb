require 'test_helper'

module Frontend
  class HomeControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

    test "should get index with a conference that has more events than the limit" do
      conference = create(:conference)
      (Frontend::HomeController::EVENT_LIMIT + 1).times { create(:event, conference: conference) }

      get :index
      assert_response :success
      assert_includes @response.body, "more videos from #{conference.display_name}"
    end

    test "should get about" do
      get :about
      assert_response :success
    end
  end
end
