require 'test_helper'

class Api::RecordingsControllerTest < ActionController::TestCase
  setup do
    @key = create(:api_key)
    create :conference_with_recordings
  end

  test 'should list recent recordings' do
    get 'index', format: :json, api_key: @key.key
    assert_response :success
    assert JSON.parse(response.body)
  end

  test 'should create recording' do
    args = { original_url: 'http://example.com',
             filename: 'test.mp3',
             folder: 'mp3s',
             mime_type: 'audio/ogg',
             size: '123',
             length: '456' }
    assert_difference('Recording.count') do
      post 'create', format: :json, api_key: @key.key, guid: Event.first.guid, recording: args
    end
    assert_response :success
    assert JSON.parse(response.body)
    recording = assigns(:recording)
    assert '123', recording.size
    assert '456', recording.length
    assert 'audio/ogg', recording.mime_type
    assert 'mp3s', recording.folder
    assert 'test.mp3', recording.filename
  end
end
