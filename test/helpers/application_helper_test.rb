# test/helpers/application_helper_test.rb
require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'returns "0" for 0 views' do
    assert_equal '0', human_readable_views_count(0)
  end

  test 'returns "1" for 1 view' do
    assert_equal '1', human_readable_views_count(1)
  end

  test 'returns "500" for 500 views' do
    assert_equal '500', human_readable_views_count(500)
  end

  test 'returns "999" for 999 views' do
    assert_equal '999', human_readable_views_count(999)
  end

  test 'returns "1.0k" for 1000 views' do
    assert_equal '1.0k', human_readable_views_count(1000)
  end

  test 'returns "10.0k" for 10000 views' do
    assert_equal '10.0k', human_readable_views_count(10000)
  end

  test 'returns "100.0k" for 100000 views' do
    assert_equal '100.0k', human_readable_views_count(100000)
  end
end
