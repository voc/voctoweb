require 'test_helper'

class Api::RecordingsControllerTest < ActionController::TestCase
  setup do
    @key = create(:api_key)
    create :conference_with_recordings
  end

  test 'should list recent recordings' do
    get 'index', format: :json, params: { api_key: @key.key }
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
      post 'create', format: :json, params: { api_key: @key.key, guid: Event.first.guid, recording: args }
    end
    assert_response :success
    assert JSON.parse(response.body)
    recording = assigns(:recording)
    assert_equal 123, recording.size
    assert_equal 456, recording.length
    assert_equal 'audio/ogg', recording.mime_type
    assert_equal 'mp3s', recording.folder
    assert_equal 'test.mp3', recording.filename
  end

  test 'should create recording2' do
    args = { filename: 'test.mp4',
             folder: 'mp4s',
             mime_type: 'video/mp4',
             html5: false,
             language: 'deu-eng',
             width: '1920',
             height: '1080',
             high_quality: true,
             size: '123',
             length: '456' }
    assert_difference('Recording.count') do
      post 'create', format: :json, params: { api_key: @key.key, guid: Event.first.guid, recording: args }
    end
    assert_response :success
    assert JSON.parse(response.body)
    recording = assigns(:recording)
    refute recording.html5
    assert recording.high_quality
    assert_equal 123, recording.size
    assert_equal 456, recording.length
    assert_equal 'video/mp4', recording.mime_type
    assert_equal 'mp4s', recording.folder
    assert_equal 'test.mp4', recording.filename
    assert_equal 'deu-eng', recording.language
  end
end
