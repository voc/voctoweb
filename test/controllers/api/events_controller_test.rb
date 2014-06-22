require 'test_helper'

class Api::EventsControllerTest < ActionController::TestCase

  setup do
    @key = create(:api_key)
  end

  test "should list recent events" do
    create(:event)
    get 'index', format: :json, api_key: @key.key
    assert_response :success
    assert JSON.parse(response.body)
  end

  test "should list events of conference" do
    ACRONYM = 'frabcon123'
    conference = create(:conference, acronym: ACRONYM)
    create(:event, conference: conference)
    create(:event, conference: conference)
    create(:event, conference: conference)
    get 'index', format: :json, api_key: @key.key, acronym: ACRONYM
    events = JSON.parse(response.body)
    assert events.size > 2
  end

  test "should update promoted flag according to view count of events" do
    conference = create(:conference)
    events = []
    events << create(:event, conference: conference, view_count: 1)
    events << create(:event, conference: conference, view_count: 2)
    events << create(:event, conference: conference, view_count: 3)

    get 'update_promoted', format: :json, api_key: @key.key
    events.each { |event| assert Event.find(event.id).promoted }
  end

end
