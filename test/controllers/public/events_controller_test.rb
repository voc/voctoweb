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
    refute_empty JSON.parse(response.body)
    #puts JSON.pretty_generate JSON.parse(response.body)
  end

  test 'should get show' do
    get :show, params: { id: @event.id }, format: :json
    assert_response :success
    assert_equal @event, assigns(:event)
    refute_empty JSON.parse(response.body)
    # puts JSON.pretty_generate JSON.parse(response.body)
  end

  test 'should get show with uuid' do
    get :show, params: { id: @event.guid }, format: :json
    assert_response :success
    assert_equal @event, assigns(:event)
  end
end
