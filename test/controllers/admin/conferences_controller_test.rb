require 'test_helper'

class Admin::ConferencesControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should list conferences" do
    create :conference
    get 'index'
    assert_response :success
  end

  test "should show new conference form" do
    get 'new'
    assert_response :success
  end

  test "should show a conference" do
    conference = create :conference
    get 'show', params: { id: conference.id }
    assert_response :success
  end

end
