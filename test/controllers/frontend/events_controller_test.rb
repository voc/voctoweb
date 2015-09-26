require 'test_helper'

module Frontend
  class EventsControllerTest < ActionController::TestCase
    test "should get show" do
      get :show, { conference_slug: '123', slug: 'abc' }
      assert_response :success
    end
    test "should get oembed" do
      get :oembed, { conference_slug: '123', slug: 'abc' }
      assert_response :success
    end
    test "should get download" do
      get :download, { conference_slug: '123', slug: 'abc' }
      assert_response :success
    end
  end
end
