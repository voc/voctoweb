require 'test_helper'

class Public::RecordingsControllerTest < ActionController::TestCase
  test 'should get index' do
    create :conference_with_recordings
    get :index, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
    # puts JSON.pretty_generate JSON.parse(response.body)
  end

  test 'should get show' do
    create :conference_with_recordings
    recording = Recording.first
    get :show, params: { id: recording.id }, format: :json
    assert_response :success
    assert assigns(:recording)
    refute_empty JSON.parse(response.body)
    # puts JSON.pretty_generate JSON.parse(response.body)
  end

  test 'should increase view count' do
    create :conference_with_recordings
    e = Event.first
    r = e.recordings.first
    post :count, params: { event_id: e.id, src: r.filename }, format: :json
    assert_response :success
    refute_empty JSON.parse(response.body)
    assert_equal 'ok', JSON.parse(response.body)['status']
    assert RecordingView.count > 0
    Event.update_view_counts
    assert Event.first.view_count > 0
  end
end
