require 'test_helper'

class StorageControllerTest < ActionController::TestCase
  test "should get import_conference" do
    get :import_conference
    assert_response :success
  end

end
