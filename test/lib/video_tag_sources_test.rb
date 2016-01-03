require 'test_helper'

class VideoTagSourcesImporterTest < ActiveSupport::TestCase
  def setup
    create(:conference_with_recordings)
    @event = Frontend::Event.first
  end

  def test_build
    create :recording, language: 'de', mime_type: 'vnd.voc/mp4-web', state: 'downloaded', filename: 'video1.mp4', event: @event
    create :recording, language: 'en', mime_type: 'vnd.voc/mp4-web', state: 'downloaded', filename: 'video2.mp4', event: @event
    create :recording, language: 'en-de', mime_type: 'vnd.voc/mp4-web', state: 'downloaded', filename: 'video3.mp4', event: @event

    sources = VideoTagSources.new(Frontend::Recording.all, MimeType::WEB_PREFERRED_VIDEO).build
    assert_equal 2, sources.count
    refute sources.detect { |r| r.filename == 'video1.mp4' }
    refute sources.detect { |r| r.filename == 'video3.mp4' }
    assert sources.detect { |r| r.filename == 'video2.mp4' }
  end

  def test_build_prefers_web
    create :recording, language: 'en', mime_type: 'video/mp4', state: 'downloaded', filename: 'video4.mp4', event: @event
    create :recording, language: 'en', mime_type: 'vnd.voc/mp4-web', state: 'downloaded', filename: 'video2.mp4', event: @event

    sources = VideoTagSources.new(Frontend::Recording.all, MimeType::WEB_PREFERRED_VIDEO).build
    assert_equal 2, sources.count
    refute sources.detect { |r| r.filename == 'video4.mp4' }
    assert sources.detect { |r| r.filename == 'video2.mp4' }
  end

  def test_build_complex
    create :recording, state: :downloaded, event: @event, mime_type: 'video/mp4', filename: 'en-Schweigen_sd.mp4', language: 'en'
    create :recording, state: :downloaded, event: @event, mime_type: 'video/webm', filename: 'en-Schweigen_webm-sd.webm', language: 'en'
    create :recording, state: :downloaded, event: @event, mime_type: 'vnd.voc/webm-hd', filename: 'en-Schweigen_webm-hd.webm', language: 'en'
    create :recording, state: :downloaded, event: @event, mime_type: 'vnd.voc/mp4-web', filename: 'de-Schweigen.mp4', language: 'de'
    create :recording, state: :downloaded, event: @event, mime_type: 'vnd.voc/mp4-web', filename: 'en-Schweigen.mp4', language: 'en'
    create :recording, state: :downloaded, event: @event, mime_type: 'vnd.voc/h264-hd', filename: 'de-en-Schweigen_hd.mp4', language: 'de-en'
    @event.update(original_language: :de)

    sources = VideoTagSources.new(Frontend::Recording.all, MimeType::WEB_PREFERRED_VIDEO).build
    assert_equal 2, sources.count
    assert sources.detect { |r| r.filename == 'en-Schweigen_webm-hd.webm' }
    assert sources.detect { |r| r.filename == 'de-Schweigen.mp4' }
  end
end
