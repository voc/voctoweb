require 'test_helper'

class PublicControllerTest < ActionController::TestCase
  test "should get index" do
    create :conference_with_recordings
    get :index, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
  end

  test "should get oembed" do
    conference = create :conference_with_recordings
    get :oembed, url: event_url(slug: conference.events.first.slug)
    assert_response :success
    refute_empty JSON.parse(response.body)
  end

end
