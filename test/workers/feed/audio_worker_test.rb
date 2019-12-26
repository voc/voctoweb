require 'test_helper'

class Feed::AudioWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_audio_recordings)
    @conference.events.update_all(release_date: Time.now)

    @worker = Feed::AudioWorker.new
  end

  def test_perform
    assert_difference('WebFeed.count') do
      assert @worker.perform
    end

    f = WebFeed.first
    assert_equal 'podcast_audio', f.key
    assert_nil f.kind
    refute_empty f.content

    items = xml_rss_items(f.content)
    assert_equal 1, items.size
  end
end
