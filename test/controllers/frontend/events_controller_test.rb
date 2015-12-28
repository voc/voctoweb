require 'test_helper'

module Frontend
  class EventsControllerTest < ActionController::TestCase
    def setup
      conference = create :conference, slug: '123'
      @event = create :event, conference: conference, slug: 'abc'
    end

    test 'should get show with slug' do
      get :show, slug: @event.slug
      assert_response :success
      assert_equal @event.id, assigns(:event).id
    end

    test 'should get show' do
      get :show, slug: 'abc'
      assert_response :success
    end

    test 'should get oembed' do
      get :oembed, slug: 'abc'
      assert_response :success
      get :oembed, slug: 'abc', width: 12, height: 13
      assert_equal "12", assigns(:width)
    end

    test 'should get download' do
      get :download, slug: 'abc'
      assert_response :success
    end
  end
end
