require 'test_helper'

class Public::EventsControllerTest < ActionController::TestCase
  setup do
    create :conference_with_recordings
    @event = Event.first
  end

  test "should get index" do
    create :conference_with_recordings
    get :index, format: :json
    assert_response :success
    json = JSON.parse(response.body)
    refute_empty json
    refute_empty json['events'][0]['url']
    assert_equal ['Name'], json['events'][0]['persons']
  end

  test 'should get show' do
    get :show, params: { id: @event.id }, format: :json
    assert_response :success
    assert_equal @event, assigns(:event)
    json = JSON.parse(response.body)
    #puts JSON.pretty_generate json
    refute_empty json
    refute_empty json['tags']
    refute_empty json['recordings']
  end

  test 'should get show with uuid' do
    get :show, params: { id: @event.guid }, format: :json
    assert_response :success
    assert_equal @event, assigns(:event)
  end

  test 'redirects to page not found' do
    get :show, params: { id: 'notexisting' }, format: :json
    assert_response :not_found
  end

  unless ENV['SKIP_ELASTICSEARCH']
    test 'search for events' do
      get :search, params: { q: 'not-existing' }, format: :json
      assert_response :success
      json = JSON.parse(response.body)
      assert_empty json['events']
    end

    test 'search for events return multiple results' do
      Event.__elasticsearch__.create_index! force: true
      create_list(:event, 26, title: 'fake-event')
      Event.import
      Event.__elasticsearch__.refresh_index!

      get :search, params: { q: 'fake-event' }, format: :json
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 25, json['events'].count

      get :search, params: { q: 'fake-event', page: '2' }, format: :json
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 1, json['events'].count
    end
  end
end
