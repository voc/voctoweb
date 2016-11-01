require 'test_helper'

class Admin::AdminUsersControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should list admin users" do
    create :admin_user
    get 'index'
    assert_response :success
  end

  test "should show new admin users form" do
    get 'new'
    assert_response :success
  end

  test "should show an admin user" do
    user = create :admin_user
    get 'show', params: { id: user.id }
    assert_response :success
  end

end
