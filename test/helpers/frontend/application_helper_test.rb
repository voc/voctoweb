require 'test_helper'

class Frontend::ApplicationHelperTest < ActionView::TestCase
  test '#video_tag_sources' do
    create(:conference_with_recordings)
    event = Frontend::Event.first
    create :recording, language: 'de', mime_type: 'vnd.voc/mp4-web', state: 'downloaded', filename: 'video1.mp4', event: event
    create :recording, language: 'en', mime_type: 'vnd.voc/mp4-web', state: 'downloaded', filename: 'video2.mp4', event: event
    create :recording, language: 'en-de', mime_type: 'vnd.voc/mp4-web', state: 'downloaded', filename: 'video3.mp4', event: event
    sources = video_tag_sources(Frontend::Recording.all)

    assert_equal 2, sources.count
    assert_equal 'en', sources.last.language
  end
end
