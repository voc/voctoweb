require 'test_helper'

class GraphqlControllerTest < ActionController::TestCase
  setup do
      @conference = create :conference_with_recordings
  end

  test 'should list conferences' do
    post 'execute', params: { 
      query: " {
        allConferences(first:10) {id, title}
      } "
    }
    assert_response :success
    assert JSON.parse(response.body)
  end
end