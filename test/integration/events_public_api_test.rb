require 'test_helper'

class EventsPublicApiTest < ActionDispatch::IntegrationTest
  test 'should get event via public api' do
    @conference = create(:conference_with_recordings)
    event = Event.last
    event.update(slug: 'test.slug')
    get_json "/public/events/test.slug", {}
    assert_response :success
    assert JSON.parse(response.body)
    assert response.body.include?(event.guid)
    assert_equal 'application/json', response.headers['Content-Type']
  end
end
