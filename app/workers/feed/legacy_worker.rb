class Feed::LegacyWorker < Feed::Base
  include Sidekiq::Worker

  key :podcast_legacy
  channel_title 'recent events feed'
  channel_summary ' This feed contains events from the last two years'

  def perform(*args)
    events = downloaded_events.newer(last_year)
    start_time = events.maximum(:updated_at)

    WebFeed.update_with_lock(start_time, key: key) do |feed|
      feed.content = generator.generate(events, &:preferred_recording)
    end
  end
end
