require 'test_helper'

class Feed::PodcastWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_recordings)
    @conference.events.update_all(release_date: Time.now)

    @worker = Feed::PodcastWorker.new
  end

  def test_perform
    assert_difference('WebFeed.count', 3) do
      assert @worker.perform
    end

    f = WebFeed.find_by(kind: 'hq', key: 'podcast')
    refute_empty f.content

    items = xml_rss_items(f.content)
    assert_equal 2, items.size
  end

  def test_hq_feed_selects_highest_resolution
    event = create(:event, release_date: Time.now, conference: @conference)

    rec_480p = create(:recording, :video_480p, event: event, filename: '480p.webm')
    rec_1080p = create(:recording, :video_1080p, event: event, filename: '1080p.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'hq', key: 'podcast')
    assert_includes f.content, '1080p.webm'
    refute_includes f.content, '480p.webm'
  end

  def test_lq_feed_only_includes_recordings_below_720p
    event1 = create(:event, release_date: Time.now, conference: @conference)
    event2 = create(:event, release_date: Time.now, conference: @conference)

    # Event1: only high-res
    create(:recording, :video_1080p, event: event1, filename: 'hd.webm')

    # Event2: has low-res
    create(:recording, :video_480p, event: event2, filename: 'sd.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'lq', key: 'podcast')
    items = xml_rss_items(f.content)

    # Only event2 should be in LQ feed
    assert_includes f.content, 'sd.webm'
    refute_includes f.content, 'hd.webm'
  end

  def test_excludes_translated_recordings
    event = create(:event, release_date: Time.now, conference: @conference)

    rec_orig = create(:recording, :video_1080p, event: event, filename: 'orig.webm')
    rec_trans = create(:recording, :video_1080p, :translated, event: event, filename: 'trans.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'hq', key: 'podcast')
    assert_includes f.content, 'orig.webm'
    refute_includes f.content, 'trans.webm'
  end

  def test_prefers_mp4_over_webm_when_both_available
    event = create(:event, release_date: Time.now, conference: @conference)

    rec_mp4 = create(:recording, :video_1080p, :mp4, event: event, filename: 'video.mp4')
    rec_webm = create(:recording, :video_1080p, :webm, event: event, filename: 'video.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'hq', key: 'podcast')
    # Should prefer MP4 according to PREFERRED_VIDEO order
    assert_includes f.content, 'video.mp4'
    refute_includes f.content, 'video.webm'
  end

  def test_master_feed_prefers_multilingual
    event = create(:event, release_date: Time.now, conference: @conference)

    rec_single = create(:recording, :video_1080p, event: event, filename: 'single.webm', language: 'eng', html5: false)
    rec_multi = create(:recording, :video_1080p, :multilingual, event: event, filename: 'multi.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'master', key: 'podcast')
    assert_includes f.content, 'multi.webm'
    refute_includes f.content, 'single.webm'
  end
end
