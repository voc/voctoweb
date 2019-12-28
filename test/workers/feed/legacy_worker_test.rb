require 'test_helper'

class Feed::LegacyWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_recordings)
    @conference.events.update_all(release_date: Time.now)

    @worker = Feed::LegacyWorker.new
  end

  def test_perform
    assert_difference('WebFeed.count') do
      assert @worker.perform
    end

    f = WebFeed.first
    assert_equal 'podcast_legacy', f.key
    assert_nil f.kind
    refute_empty f.content

    items = xml_rss_items(f.content)
    assert_equal 2, items.size
  end
end
