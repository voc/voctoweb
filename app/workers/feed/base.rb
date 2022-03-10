class Feed::Base
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

  def view_context
    # conference_url, event_url, image_url
    view = ActionView::Base.new(ActionController::Base.view_paths, {}, nil)
    view.class.include Rails.application.routes.url_helpers
    view.class.include ApplicationHelper
    Rails.application.routes.default_url_options[:host] = Settings.frontend_host
    Rails.application.routes.default_url_options[:protocol] = Settings.frontend_proto
    view
  end

  def logo_image_url
    view_context.image_url('frontend/feed-banner.png')
  end

  def generator
    Feeds::PodcastGenerator.new(
      view_context,
      title: self.class.get_title,
      channel_summary: self.class.get_summary,
      logo_image: logo_image_url
    )
  end
end
