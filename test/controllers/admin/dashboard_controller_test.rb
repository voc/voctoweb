require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should show dashboard" do
    get 'index'
    assert_response :success
  end

  test "should show dashboard with a conference" do
    create :conference
    get :index
    assert_response :success
  end

end
