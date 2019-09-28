require 'test_helper'

module Frontend
  class EventsControllerTest < ActionController::TestCase
    def setup
      @conference = create :conference, slug: '123'
      @event = create :event, conference: @conference, slug: 'abc'
      @recording  = create :recording, event: @event, filename: 'abc', mime_type: 'video/mp4', language: 'eng'
    end

    test 'should get show with slug' do
      get :show, params: { slug: @event.slug }
      assert_response :success
      assert_equal @event.id, assigns(:event).id
    end

    test 'should get show' do
      get :show, params: { slug: 'abc' }
      assert_response :success
    end

    test 'should get oembed' do
      get :oembed, params: { slug: 'abc' }
      assert_response :success
      get :oembed, params: { slug: 'abc', width: 12, height: 13 }
      assert_equal "12", assigns(:width)
    end

    test 'should get postroll' do
      other_event = create :event, conference: @conference, slug: 'efg'
      get :postroll, params: { slug: 'abc' }
      assert_response :success
    end
  end
end
