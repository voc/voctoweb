class Feed::AudioWorker < Feed::Base
  include Sidekiq::Worker

  key :podcast_audio
  channel_title 'recent audio-only feed'
  channel_summary ' This feed contains audio files from the last year'

  def perform(*args)
    events = downloaded_events.newer(last_year)
    start_time = events.maximum(:updated_at)

    WebFeed.update_with_lock(start_time, key: key) do |feed|
      feed.content = generator.generate(events, &:audio_recording)
    end
  end
end
