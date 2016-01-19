require 'test_helper'

class Public::EventsControllerTest < ActionController::TestCase
  setup do
    create :conference_with_recordings
    @event = Event.first
  end

  test 'should get show' do
    get :show, id: @event.id, format: :json
    assert_response :success
    assert_equal @event, assigns(:event)
    refute_empty JSON.parse(response.body)
    # puts JSON.pretty_generate JSON.parse(response.body)
  end

  test 'should get find' do
    get :find, id: @event.guid, format: :json
    assert_response :success
    assert_equal @event, assigns(:event)
  end
end
