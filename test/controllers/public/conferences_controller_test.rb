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

  test "index filters by url_contains" do
    matching = create :conference_with_recordings, link: 'https://example.org/match'
    other = create :conference_with_recordings, link: 'https://example.org/other'

    get :index, params: { url_contains: 'match' }, format: :json
    assert_response :success
    acronyms = JSON.parse(response.body)['conferences'].map { |c| c['acronym'] }
    assert_includes acronyms, matching.acronym
    refute_includes acronyms, other.acronym
  end

  test "index filters by currently_streaming" do
    streaming = create :conference_with_recordings, streaming: { 'isCurrentlyStreaming' => true }
    not_streaming = create :conference_with_recordings

    get :index, params: { currently_streaming: 'true' }, format: :json
    assert_response :success
    acronyms = JSON.parse(response.body)['conferences'].map { |c| c['acronym'] }
    assert_includes acronyms, streaming.acronym
    refute_includes acronyms, not_streaming.acronym
  end

  test "should get recent" do
    conference = create :conference_with_recordings
    conference.update_column(:event_last_released_at, Time.current)

    get :recent, params: { limit: 1 }, format: :json
    assert_response :success
    acronyms = JSON.parse(response.body)['conferences'].map { |c| c['acronym'] }
    assert_includes acronyms, conference.acronym
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
