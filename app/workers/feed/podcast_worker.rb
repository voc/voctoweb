class Feed::PodcastWorker < Feed::Base
  include Sidekiq::Worker

  key :podcast

  def perform(*args)
    events = downloaded_events.newer(last_year)
    start_time = events.maximum(:updated_at)

    Frontend::FeedQuality.all.each do |quality|
      WebFeed.update_with_lock(start_time, key: key, kind: quality) do |feed|
        feed.content = build(events, quality)
      end
    end
  end

  private

  def build(events, quality)
    generator = Feeds::PodcastGenerator.new(
      view_context,
      title: "recent events feed (#{Frontend::FeedQuality.display_name(quality)})",
      channel_summary: ' This feed contains events from the last two years',
      logo_image: logo_image_url
    )
    generator.generate(events) do |event|
      Frontend::EventRecordingFilter.by_quality_string(quality).filter(event)
    end
  end
end
