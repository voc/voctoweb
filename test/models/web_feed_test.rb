require 'test_helper'

class WebFeedTest < ActiveSupport::TestCase
  test 'round_to_next_quarter_hour' do
    time = WebFeed.round_to_quarter_hour(Time.parse('2017-02-12 14:21:42 +00000'))
    assert_equal Time.parse('2017-02-12 14:15:00 +0000'), time

    time = WebFeed.round_to_quarter_hour(Time.parse('2017-02-12 17:38:10 +00000'))
    assert_equal Time.parse('2017-02-12 17:30:00 +0000'), time

    time = WebFeed.round_to_quarter_hour(Time.parse('2017-02-12 17:46:10 +00000'))
    assert_equal Time.parse('2017-02-12 17:45:00 +0000'), time
  end
end
