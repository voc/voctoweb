require 'test_helper'

class Frontend::SearchControllerTest < ActionController::TestCase
  setup do
    Event.__elasticsearch__.create_index! force: true
    create_list(:conference_with_recordings, 5)
  end

  test 'should get index' do
    Event.import
    Event.__elasticsearch__.refresh_index!
    get :index, params: { q: 'FrabCon' }
    assert_response :success
    assert_equal 25, assigns(:events).count
  end
end
