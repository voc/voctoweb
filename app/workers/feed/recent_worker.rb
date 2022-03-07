class Feed::RecentWorker < Feed::Base
  include Sidekiq::Worker

  key :rdftop100
  channel_title 'last 100 events feed'
  channel_summary ' This feed the most recent 100 events'

  def perform(*args)
    events = downloaded_events.recent(100)
    start_time = events.maximum(:updated_at)

    generator = Feeds::RdfGenerator.new(
      view_context: view_context,
      config: {
        title: self.class.get_title,
        channel_summary: self.class.get_summary,
        logo_image: logo_image_url
      }
    )
    WebFeed.update_with_lock(start_time, key: key) do |feed|
      feed.content = generator.generate(events)
    end
  end
end
