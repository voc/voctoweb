class Feed::ArchiveLegacyWorker < Feed::Base
  include Sidekiq::Worker

  key :podcast_archive_legacy
  channel_title 'archive feed'
  channel_summary ' This feed contains events older than two years'

  def perform(*args)
    events = downloaded_events.older(last_year)
    start_time = events.maximum(:updated_at)

    WebFeed.update_with_lock(start_time, key: key) do |feed|
      feed.content = generator.generate(events, &:preferred_recording)
    end
  end
end
