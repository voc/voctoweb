require 'test_helper'

module Frontend
  class FeedsControllerTest < ActionController::TestCase
    setup do
      @conference = create :conference_with_recordings
    end

    test 'should get podcast' do
      get :podcast, format: :xml
      assert_response :success
    end

    test 'should get podcast_archive' do
      get :podcast_archive, format: :xml
      assert_response :success
    end

    test 'should get podcast audio only' do
      get :podcast_audio, format: :xml
      assert_response :success
    end

    test 'should get updates' do
      get :updates, format: :xml
      assert_response :success
    end

    test 'should get podcast_folder' do
      get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm' }, format: :xml
      assert_response :success
    end
  end
end
