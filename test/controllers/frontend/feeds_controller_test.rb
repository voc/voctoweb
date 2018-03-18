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

    test 'should get podcast low quality' do
      get :podcast, params: { quality: FeedQuality::LQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast high quality' do
      get :podcast, params: { quality: FeedQuality::HQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast_archive_legacy' do
      get :podcast_archive_legacy, format: :xml
      assert_response :success
    end

    test 'should get podcast_archive in low quality' do
      get :podcast_archive, params: { quality: FeedQuality::LQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast_archive in high quality' do
      get :podcast_archive, params: { quality: FeedQuality::HQ }, format: :xml
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

    test 'should get podcast_folder legacy' do
      get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm' }, format: :xml
      assert_response :success
    end

    test 'should raise if podcast_folder with invalid quality' do
      assert_raise ActiveRecord::RecordNotFound do
        get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm', quality: 'exhaust memory' }, format: :xml
      end
    end

    test 'should get podcast_folder hq' do
      get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm', quality: FeedQuality::HQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast_folder lq' do
      get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm', quality: FeedQuality::LQ }, format: :xml
      assert_response :success
    end

    test 'round_to_next_quarter_hour' do
      time = @controller.send(:round_to_quarter_hour, Time.parse('2017-02-12 14:21:42 +00000'))
      assert_equal time, Time.parse('2017-02-12 14:15:00 +0000')

      time = @controller.send(:round_to_quarter_hour, Time.parse('2017-02-12 17:38:10 +00000'))
      assert_equal time, Time.parse('2017-02-12 17:30:00 +0000')

      time = @controller.send(:round_to_quarter_hour, Time.parse('2017-02-12 17:46:10 +00000'))
      assert_equal time, Time.parse('2017-02-12 17:45:00 +0000')
    end
  end
end
