require 'test_helper'

class Admin::EventsControllerTest < ActionController::TestCase

  setup do
    @user = create :admin_user
    sign_in @user
  end

  test "should list events" do
    get 'index'
    assert_response :success
  end

  test "should show new event form" do
    get 'new'
    assert_response :success
  end

  test "should show an event" do
    event = create :event
    get 'show', params: { id: event.id }
    assert_response :success
  end

  test "should error for non-existing event" do
    assert_raise ActiveRecord::RecordNotFound do
      get 'show', params: { id: 1234 }
    end
  end

end
