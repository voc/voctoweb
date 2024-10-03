class Feed::Base
  include ActionView::Helpers

  def initialize
    Rails.application.routes.default_url_options[:host] = Settings.frontend_host
    Rails.application.routes.default_url_options[:protocol] = Settings.frontend_proto
  end

  def self.key(n)
    @name = n
  end

  def self.get_key
    @name
  end

  def key
    self.class.get_key
  end

  def self.channel_title(n)
    @title = n
  end

  def self.get_title
    @title
  end

  def self.channel_summary(n)
    @summary = n
  end

  def self.get_summary
    @summary
  end

  def downloaded_events
    Frontend::Event.published.includes(:conference)
  end

  def last_year
    WebFeed.last_year
  end

  def logo_image_url
    image_url('frontend/feed-banner.png')
  end

  def generator
    Feeds::PodcastGenerator.new(
      title: self.class.get_title,
      channel_summary: self.class.get_summary,
      logo_image: logo_image_url
    )
  end
end
