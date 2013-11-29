require 'test_helper'

class Admin::EventInfosControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should list event infos" do
    get 'index'
    assert_response :success
  end

  test "should show new event info form" do
    get 'new'
    assert_response :success
  end

  test "should show an event info" do
    event_info = create :event_info
    get 'show', id: event_info.id
    assert_response :success
  end

end
