require 'test_helper'

class Admin::RecordingsControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should list recordings" do
    get 'index'
    assert_response :success
  end

  test "should show new recording form" do
    get 'new'
    assert_response :success
  end

  test "should show a recording" do
    recording = create :recording
    get 'show', params: { id: recording.id }
    assert_response :success
  end

end
