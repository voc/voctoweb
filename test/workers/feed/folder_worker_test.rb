require 'test_helper'

class Feed::FolderWorkerTest < ActiveSupport::TestCase
  def setup
    @worker = Feed::FolderWorker.new
  end

  def test_perform
    @conference = create(:conference_with_recordings)

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

  def test_perform_audio
    @conference = create(:conference_with_audio_recordings)

    assert_difference('WebFeed.count', 4) do
      assert @worker.perform @conference.id
    end

    f = WebFeed.find_by!(kind: @conference.acronym+'mp3', key: 'podcast_folder')
    assert_includes f.content, "<link>https://media.ccc.de/v/#{@conference.events.last.slug}</link>"
    refute_empty f.content
  end

  def test_hq_feed_selects_highest_resolution
    @conference = create(:conference)
    event = create(:event, conference: @conference, release_date: '2024-01-01')

    # Create recordings with different resolutions (same MIME type)
    rec_480p = create(:recording, event: event, mime_type: 'video/webm', width: 854, height: 480, filename: '480p.webm')
    rec_720p = create(:recording, event: event, mime_type: 'video/webm', width: 1280, height: 720, filename: '720p.webm')
    rec_1080p = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080, filename: '1080p.webm')

    @worker.perform @conference.id

    f = WebFeed.find_by!(kind: @conference.acronym+'hqwebm', key: 'podcast_folder')
    items = xml_rss_items(f.content)
    assert_equal 1, items.size

    # Verify the 1080p recording was selected
    assert_includes f.content, '1080p.webm'
    refute_includes f.content, '720p.webm'
    refute_includes f.content, '480p.webm'
  end

  def test_lq_feed_excludes_recordings_above_720p
    @conference = create(:conference)
    event1 = create(:event, conference: @conference, release_date: '2024-01-01')
    event2 = create(:event, conference: @conference, release_date: '2024-01-02')

    # Event1: only 1080p (should be excluded from LQ feed)
    create(:recording, event: event1, mime_type: 'video/webm', width: 1920, height: 1080, filename: '1080p.webm')

    # Event2: has 480p (should be included)
    create(:recording, event: event2, mime_type: 'video/webm', width: 1920, height: 1080, filename: 'event2_1080p.webm')
    create(:recording, event: event2, mime_type: 'video/webm', width: 854, height: 480, filename: 'event2_480p.webm')

    @worker.perform @conference.id

    f = WebFeed.find_by!(kind: @conference.acronym+'lqwebm', key: 'podcast_folder')
    items = xml_rss_items(f.content)

    # Only event2 should appear (has <720p recording)
    assert_equal 1, items.size
    assert_includes f.content, 'event2_480p.webm', "LQ feed should select the 480p recording"
    refute_includes f.content, 'event2_1080p.webm', "LQ feed should not select 1080p even if available"
  end

  def test_feed_excludes_translated_recordings
    @conference = create(:conference)
    event = create(:event, conference: @conference, release_date: '2024-01-01')

    # Original recording
    rec_original = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080,
                          filename: 'original.webm', translated: false, language: 'eng')
    # Translated recording (simultaneous interpretation)
    rec_translated = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080,
                            filename: 'translated.webm', translated: true, language: 'deu')

    @worker.perform @conference.id

    f = WebFeed.find_by!(kind: @conference.acronym+'hqwebm', key: 'podcast_folder')

    # Should only include the non-translated recording
    assert_includes f.content, 'original.webm'
    refute_includes f.content, 'translated.webm'
  end

  def test_feed_excludes_slides
    @conference = create(:conference)
    event = create(:event, conference: @conference, release_date: '2024-01-01')

    # Regular video
    rec_video = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080,
                       filename: 'talk.webm', folder: 'webm-hd')
    # Slides (should be excluded)
    rec_slides = create(:recording, event: event, mime_type: 'video/mp4', width: 1920, height: 1080,
                        filename: 'slides.mp4', folder: 'slides')

    @worker.perform @conference.id

    f = WebFeed.find_by!(kind: @conference.acronym+'hqwebm', key: 'podcast_folder')

    assert_includes f.content, 'talk.webm'
    refute_includes f.content, 'slides.mp4'
  end

  def test_feed_prefers_mp4_over_webm
    @conference = create(:conference)
    event = create(:event, conference: @conference, release_date: '2024-01-01')

    # Both same resolution, different MIME types
    rec_webm = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080, filename: 'video.webm')
    rec_mp4 = create(:recording, event: event, mime_type: 'video/mp4', width: 1920, height: 1080, filename: 'video.mp4')

    @worker.perform @conference.id

    # Check HQ MP4 feed
    f = WebFeed.find_by!(kind: @conference.acronym+'hqmp4', key: 'podcast_folder')
    assert_includes f.content, 'video.mp4'

    # Check HQ WebM feed
    f_webm = WebFeed.find_by!(kind: @conference.acronym+'hqwebm', key: 'podcast_folder')
    assert_includes f_webm.content, 'video.webm'
  end

  def test_master_feed_prefers_multilingual_recordings
    @conference = create(:conference)
    event = create(:event, conference: @conference, release_date: '2024-01-01')

    # Single language recording
    rec_single = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080,
                        filename: 'single_lang.webm', language: 'eng', html5: false)
    # Multi-language recording (e.g., original + dubbed) - must be html5: false
    rec_multi = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080,
                       filename: 'multi_lang.webm', language: 'eng-deu', html5: false)

    @worker.perform @conference.id

    f = WebFeed.find_by!(kind: @conference.acronym+'masterwebm', key: 'podcast_folder')

    # Master feed should prefer the multi-language recording
    assert_includes f.content, 'multi_lang.webm'
    refute_includes f.content, 'single_lang.webm'
  end

  def test_mime_type_filtering_with_with_mime_type
    @conference = create(:conference)
    event = create(:event, conference: @conference, release_date: '2024-01-01')

    # Different MIME types
    rec_mp4 = create(:recording, event: event, mime_type: 'video/mp4', width: 1920, height: 1080, filename: 'video.mp4')
    rec_webm = create(:recording, event: event, mime_type: 'video/webm', width: 1920, height: 1080, filename: 'video.webm')
    rec_mp3 = create(:recording, event: event, mime_type: 'audio/mpeg', filename: 'audio.mp3')

    @worker.perform @conference.id

    # MP4 feed should only have MP4
    f_mp4 = WebFeed.find_by!(kind: @conference.acronym+'hqmp4', key: 'podcast_folder')
    assert_includes f_mp4.content, 'video.mp4'
    refute_includes f_mp4.content, 'video.webm'

    # WebM feed should only have WebM
    f_webm = WebFeed.find_by!(kind: @conference.acronym+'hqwebm', key: 'podcast_folder')
    assert_includes f_webm.content, 'video.webm'
    refute_includes f_webm.content, 'video.mp4'

    # MP3 feed should only have MP3
    f_mp3 = WebFeed.find_by!(kind: @conference.acronym+'mp3', key: 'podcast_folder')
    assert_includes f_mp3.content, 'audio.mp3'
    refute_includes f_mp3.content, 'video.mp4'
  end
end
