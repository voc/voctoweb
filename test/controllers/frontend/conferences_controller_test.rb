require 'test_helper'

module Frontend
  class ConferencesControllerTest < ActionController::TestCase
    test 'should redirect if slug is not found' do
      get :browse
      assert_response :redirect
    end

    test 'should get browse for slug' do
      create :conference, slug: 'a/b/c', downloaded_events_count: 1
      create :conference, slug: 'a/e', downloaded_events_count: 1
      get :browse, params: { slug: 'a' }
      assert_response :success
      assert_template :browse
      get :browse, params: { slug: 'a/e' }
      assert_template :show
    end

    test 'should access conference via acronym' do
      create :conference, acronym: 'frabcon'
      get :show, params: { acronym: 'frabcon' }
      assert_response :success
      assert_template :show
      assert assigns(:conference)
    end
  end
end
