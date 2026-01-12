require 'test_helper'

class Feed::ArchiveWorkerTest < ActiveSupport::TestCase
  def setup
    @conference = create(:conference_with_recordings)
    # Set release dates to > 2 years ago for archive
    @conference.events.update_all(release_date: 3.years.ago)
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

  def test_hq_feed_selects_highest_resolution
    event = create(:event, release_date: 3.years.ago, conference: @conference)

    rec_480p = create(:recording, :video_480p, event: event, filename: '480p.webm')
    rec_1080p = create(:recording, :video_1080p, event: event, filename: '1080p.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'hq', key: 'podcast_archive')
    assert_includes f.content, '1080p.webm'
    refute_includes f.content, '480p.webm'
  end

  def test_lq_feed_excludes_high_resolution
    event1 = create(:event, release_date: 3.years.ago, conference: @conference)
    event2 = create(:event, release_date: 3.years.ago, conference: @conference)

    create(:recording, :video_1080p, event: event1, filename: 'hd.webm')
    create(:recording, :video_480p, event: event2, filename: 'sd.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'lq', key: 'podcast_archive')

    assert_includes f.content, 'sd.webm'
    refute_includes f.content, 'hd.webm'
  end

  def test_excludes_translated_recordings
    event = create(:event, release_date: 3.years.ago, conference: @conference)

    rec_orig = create(:recording, :video_1080p, event: event, filename: 'orig.webm')
    rec_trans = create(:recording, :video_1080p, :translated, event: event, filename: 'trans.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'hq', key: 'podcast_archive')
    assert_includes f.content, 'orig.webm'
    refute_includes f.content, 'trans.webm'
  end

  def test_only_includes_old_events
    old_event = create(:event, release_date: 3.years.ago, conference: @conference)
    recent_event = create(:event, release_date: 1.month.ago, conference: @conference)

    create(:recording, :video_1080p, event: old_event, filename: 'old.webm')
    create(:recording, :video_1080p, event: recent_event, filename: 'recent.webm')

    @worker.perform

    f = WebFeed.find_by(kind: 'hq', key: 'podcast_archive')

    # Archive should only include old events (> 2 years)
    assert_includes f.content, 'old.webm'
    refute_includes f.content, 'recent.webm'
  end
end
