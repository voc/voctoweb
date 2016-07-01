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
    args = { filename: 'test.mp3',
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

  test 'should create recording2' do
    args = { filename: 'test.mp4',
             folder: 'mp4s',
             mime_type: 'video/mp4',
             html5: 'False',
             language: 'deu-eng',
             width: '1920',
             height: '1080',
             high_quality: 'True',
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
    assert 'video/mp4', recording.mime_type
    assert 'mp4s', recording.folder
    assert 'test.mp4', recording.filename
    assert 'deu-eng', recording.language
  end
end
