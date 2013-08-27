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

end
