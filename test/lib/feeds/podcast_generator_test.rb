require 'test_helper'

module Feeds
  class PodcastGeneratorTest < ActiveSupport::TestCase
    test 'handles invalid recording.duration' do
      feed = PodcastGenerator.new(title: 'some-title', channel_summary: 'some-summary', logo_image: 'some-url')

      create_list(:event_with_recordings, 5)
      Recording.update_all(length: nil)
      events = Frontend::Event.all
      assert_nothing_raised {
        output = feed.generate(events, &:preferred_recording)
      }
    end

    test 'includes itunes:image for episodes with thumbnails' do
      feed = PodcastGenerator.new(title: 'test-title', channel_summary: 'test-summary', logo_image: 'http://example.com/logo.png')

      event = create(:event_with_recordings)
      event.update(thumb_filename: 'test-thumb.png')
      events = Frontend::Event.where(id: event.id)

      output = feed.generate(events, &:preferred_recording)

      assert_includes output, '<itunes:image'
      assert_includes output, 'test-thumb.png'
    end
  end
end
