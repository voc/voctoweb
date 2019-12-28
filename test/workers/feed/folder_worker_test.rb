require 'test_helper'

class Feed::FolderWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_recordings)
    @worker = Feed::FolderWorker.new
  end

  def test_perform
    assert_difference('WebFeed.count', 3) do
      assert @worker.perform @conference.id
    end

    f = WebFeed.find_by!(kind: @conference.acronym+'lqwebm', key: 'podcast_folder')
    refute_empty f.content
    items = xml_rss_items(f.content)
    assert_equal 0, items.size

    f = WebFeed.find_by!(kind: @conference.acronym+'hqwebm', key: 'podcast_folder')
    refute_empty f.content
    items = xml_rss_items(f.content)
    assert_equal 2, items.size
  end
end
