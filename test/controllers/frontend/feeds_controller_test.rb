require 'test_helper'

module Frontend
  class FeedsControllerTest < ActionController::TestCase
    test "should get podcast" do
      get :podcast, format: :xml
      assert_response :success
    end
    test "should get podcast audio only" do
      get :podcast_audio, format: :xml
      assert_response :success
    end

    test "should get podcast_archive" do
      get :podcast_archive, format: :xml
      assert_response :success
    end
  end
end
