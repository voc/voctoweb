require 'test_helper'

class Admin::ApiKeysControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should list api keys" do
    create :api_key
    get 'index'
    assert_response :success
  end

  test "should show new api key form" do
    get 'new'
    assert_response :success
  end

  test "should show an api key" do
    api_key = create :api_key
    get 'show', params: { id: api_key.id }
    assert_response :success
  end

end
