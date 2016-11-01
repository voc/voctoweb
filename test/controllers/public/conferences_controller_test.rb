require 'test_helper'

class Public::ConferencesControllerTest < ActionController::TestCase
  test "should get index" do
    create :conference_with_recordings
    get :index, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
    #puts JSON.pretty_generate JSON.parse(response.body)
  end

  test "should get show" do
    conference = create :conference_with_recordings
    get :show, params: { id: conference.id }, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
    #puts JSON.pretty_generate JSON.parse(response.body)
  end

  test "should return 404 error" do
    get :show, params: { id: 123 }, format: :json
    assert_response :not_found
  end
end
