require 'test_helper'

class Feed::ArchiveWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_recordings)
    @worker = Feed::ArchiveWorker.new
  end

  def test_perform
    assert_difference('WebFeed.count', 3) do
      assert @worker.perform
    end

    f = WebFeed.find_by(kind: 'hq', key: 'podcast_archive')
    refute_empty f.content

    items = xml_rss_items(f.content)
    assert_equal 2, items.size
  end
end
