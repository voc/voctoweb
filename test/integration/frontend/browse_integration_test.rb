require 'test_helper'

class Frontend::BrowseIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    create :conference, slug: 'a/b'
    create :conference, slug: 'a/c'
    create :conference, slug: 'a/d/e'
  end

  test 'should browse folders' do
    get browse_start_url
    assert_response :success
    get browse_url('a')
    assert_response :success
    get browse_url('a/d')
    assert_response :success
    get browse_url('a/d/e')
    assert_response :success
  end
end
