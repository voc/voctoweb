require 'test_helper'

class Public::EventsControllerTest < ActionController::TestCase
  test "should get index" do
    create :conference_with_recordings
    get :index, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
    #puts JSON.pretty_generate JSON.parse(response.body)
  end

  test "should get show" do
    conference = create :conference_with_recordings
    get :show, id: conference.id, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
    #puts JSON.pretty_generate JSON.parse(response.body)
  end
end
