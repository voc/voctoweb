require 'test_helper'

class Frontend::BrowseIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    create :conference, slug: 'a/b', downloaded_events_count: 1
    create :conference, slug: 'a/c', downloaded_events_count: 1
    create :conference, slug: 'a/d/e', downloaded_events_count: 1
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
