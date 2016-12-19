require 'test_helper'

class PublicJsonHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    fixed_time = '2016-12-12 12:12'
    event = build(:event_with_recordings, id: 1, updated_at: fixed_time)
    assert_equal 'js_event9cf8de2fe83a8092add513c99f6b9253c9fbf06d', json_cached_key(:event, event, event)
  end
end
