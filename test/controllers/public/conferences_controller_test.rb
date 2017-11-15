require 'test_helper'

class Public::ConferencesControllerTest < ActionController::TestCase
  test "should get index" do
    create :conference_with_recordings
    get :index, format: :json
    assert_response :success
    json = JSON.parse(response.body)
    refute_empty json['conferences']
    refute_empty json['conferences'][0]['url']
  end

  test "should get show" do
    conference = create :conference_with_recordings
    get :show, params: { id: conference.id }, format: :json
    assert_response :success
    json = JSON.parse(response.body)
    refute_empty json
    refute_empty json['acronym']
    refute_empty json['events']
    #puts JSON.pretty_generate JSON.parse(response.body)
  end

  test "should get show via acronym" do
    conference = create :conference_with_recordings
    get :show, params: { id: conference.acronym }, format: :json
    assert_response :success
    json = JSON.parse(response.body)
    refute_empty json['acronym']
  end


  test "should return 404 error" do
    get :show, params: { id: 123 }, format: :json
    assert_response :not_found
  end
end
