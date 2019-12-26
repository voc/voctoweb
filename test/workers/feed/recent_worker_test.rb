require 'test_helper'

class Feed::RecentWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_recordings)
    @worker = Feed::RecentWorker.new
  end

  def test_perform
    assert_difference('WebFeed.count') do
      assert @worker.perform
    end

    f = WebFeed.first
    assert_equal 'rdftop100', f.key
    assert_nil f.kind
    refute_empty f.content
  end
end
