require 'test_helper'

module Frontend
  class ConferencesControllerTest < ActionController::TestCase
    test 'should redirect if slug is not found' do
      get :slug
      assert_response :redirect
    end

    test 'should get index' do
      get :slug
      assert_response :redirect
    end

    test 'should get index for slug' do
      create :conference, slug: '123'
      get :slug, slug: '123'
      assert_response :success
    end
  end
end
