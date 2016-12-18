require 'test_helper'

class PublicJsonHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    fixed_time = '2016-12-12 12:12'
    event = build(:event_with_recordings, id: 1, conference_id: 123,
                  guid: 'b63275cbc54c6b50fb69a82513f340a5',
                  slug: 'xyz',
                  release_date: '2013-08-21',
                  updated_at: fixed_time, created_at: fixed_time)
    assert_equal 'js_event9cf8de2fe83a8092add513c99f6b9253c9fbf06d', json_cached_key(:event, event, event)
  end
end
