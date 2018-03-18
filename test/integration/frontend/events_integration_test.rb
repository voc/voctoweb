require 'test_helper'

class Frontend::EventsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create :conference_with_recordings
  end

  test 'should list events' do
    get browse_url(@conference.slug)
    assert_response :success
    assert_equal @conference.id, assigns(:conference).id
    assert_equal @conference.events.count, assigns(:events).count
  end

  test 'should view event' do
    event = @conference.events.first
    get event_url(slug: event.slug)
    assert_response :success
    assert_equal @conference.id, assigns(:conference).id
    assert_equal event.id, assigns(:event).id
  end

  test 'should view event with shorter url' do
    event = @conference.events.first
    get event_url(slug: event.slug)
    assert_response :success
    assert_equal @conference.id, assigns(:conference).id
    assert_equal event.id, assigns(:event).id
  end

  test 'should view recent' do
    get recent_url
    assert_response :success
  end
end
