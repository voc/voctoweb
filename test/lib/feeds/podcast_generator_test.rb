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
  end
end
