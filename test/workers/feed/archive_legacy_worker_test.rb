require 'test_helper'

class Feed::ArchiveLegacyWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_recordings)
    @worker = Feed::ArchiveLegacyWorker.new
  end

  def test_perform
    assert_difference('WebFeed.count') do
      assert @worker.perform
    end

    f = WebFeed.first
    assert_equal 'podcast_archive_legacy', f.key
    assert_nil f.kind
    refute_empty f.content

    items = xml_rss_items(f.content)
    assert_equal 2, items.size
    assert_includes items[0].elements['link'].text, Settings.frontend_url

    refute @worker.perform
  end
end
