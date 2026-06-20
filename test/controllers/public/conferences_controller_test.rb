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

  test "index excludes conferences without events by default" do
    with_events = create :conference_with_recordings
    without_events = create :conference

    get :index, format: :json
    assert_response :success
    acronyms = JSON.parse(response.body)['conferences'].map { |c| c['acronym'] }
    assert_includes acronyms, with_events.acronym
    refute_includes acronyms, without_events.acronym
  end

  test "index includes empty conferences with include_empty=true" do
    with_events = create :conference_with_recordings
    without_events = create :conference

    get :index, params: { include_empty: 'true' }, format: :json
    assert_response :success
    acronyms = JSON.parse(response.body)['conferences'].map { |c| c['acronym'] }
    assert_includes acronyms, with_events.acronym
    assert_includes acronyms, without_events.acronym
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
