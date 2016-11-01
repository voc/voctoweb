require 'test_helper'

class Api::ConferencesControllerTest < ActionController::TestCase
  setup do
    @key = create(:api_key)
  end

  test 'should list conferences' do
    get 'index', format: :json, params: { api_key: @key.key }
    assert_response :success
    assert JSON.parse(response.body)
  end
end
