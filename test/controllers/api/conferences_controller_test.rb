require 'test_helper'

class Api::ConferencesControllerTest < ActionController::TestCase
  setup do
    @key = create(:api_key)
    @conference = create(:conference, acronym: 'one')
  end

  test 'should list conferences' do
    get 'index', format: :json, params: { api_key: @key.key }
    assert_response :success
    assert JSON.parse(response.body)
  end

  test 'should update conference' do
    args =  {
      conference: {
        logo: 'fake-logo',
        title: 'fake-title'
      },
      api_key: @key.key,
      id: @conference.id
    }
    patch 'update', format: :json, params: args
    assert_response :success
    @conference.reload
    assert_equal 'fake-logo', @conference.logo
    assert_equal 'fake-title', @conference.title
  end
end
