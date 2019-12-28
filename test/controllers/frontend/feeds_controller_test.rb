require 'test_helper'

module Frontend
  class FeedsControllerTest < ActionController::TestCase
    setup do
      @conference = create :conference_with_recordings
    end

    test 'should get podcast low quality' do
      create(:web_feed_podcast, kind: 'lq')
      get :podcast, params: { quality: FeedQuality::LQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast high quality' do
      create(:web_feed_podcast)
      get :podcast, params: { quality: FeedQuality::HQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast_archive_legacy' do
      create(:web_feed, key: :podcast_archive_legacy)
      get :podcast_archive_legacy, format: :xml
      assert_response :success
    end

    test 'should get podcast_archive in low quality' do
      create(:web_feed, key: :podcast_archive, kind: 'lq')
      get :podcast_archive, params: { quality: FeedQuality::LQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast_archive in high quality' do
      create(:web_feed, key: :podcast_archive, kind: 'hq')
      get :podcast_archive, params: { quality: FeedQuality::HQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast audio only' do
      create(:web_feed)
      get :podcast_audio, format: :xml
      assert_response :success
    end

    test 'should get updates' do
      create(:web_feed, key: :rdftop100)
      get :updates, format: :xml
      assert_response :success
    end

    test 'should get podcast_folder legacy' do
      create(:web_feed_folder, key: :podcast_legacy)
      get :podcast_legacy, params: { acronym: @conference.acronym, mime_type: 'webm' }, format: :xml
      assert_response :success
    end

    test 'should raise if podcast_folder with invalid quality' do
      assert_raise ActiveRecord::RecordNotFound do
        get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm', quality: 'exhaust memory' }, format: :xml
      end
    end

    test 'should raise if podcast is not found' do
      assert_raise ActiveRecord::RecordNotFound do
        get :podcast_audio, format: :xml
      end
    end

    test 'should get podcast_folder' do
      create(:web_feed_folder, kind: WebFeed.folder_key(@conference, '', 'webm'))
      get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm' }, format: :xml
      assert_response :success
    end

    test 'should get podcast_folder hq' do
      create(:web_feed_folder, kind: WebFeed.folder_key(@conference, 'hq', 'webm'))
      get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm', quality: FeedQuality::HQ }, format: :xml
      assert_response :success
    end

    test 'should get podcast_folder lq' do
      create(:web_feed_folder, kind: WebFeed.folder_key(@conference, 'lq', 'webm'))
      get :podcast_folder, params: { acronym: @conference.acronym, mime_type: 'webm', quality: FeedQuality::LQ }, format: :xml
      assert_response :success
    end
  end
end
