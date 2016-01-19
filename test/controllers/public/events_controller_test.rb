require 'test_helper'

class Public::EventsControllerTest < ActionController::TestCase
  test "should get show" do
    create :conference_with_recordings
    event = Event.first
    get :show, id: event.id, format: :json
    assert_response :success
    assert assigns(:event)
    refute_empty JSON.parse(response.body)
    #puts JSON.pretty_generate JSON.parse(response.body)
  end
end
