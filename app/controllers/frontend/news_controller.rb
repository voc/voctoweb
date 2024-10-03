module Frontend
  class NewsController < FrontendController
    include ActionView::Helpers::AssetUrlHelper

    def index
      news = News.latest_first
      atom_feed = Feeds::NewsFeedGenerator.generate(news,
        options: {
          author: Settings.feeds[:channel_owner],
          title: I18n.t('custom.news_title'),
          feed_url: news_url,
          icon: File.join(Settings.frontend_url, 'favicon.ico'),
          logo: image_url('frontend/voctocat.svg')
        })
      respond_to do |format|
        format.xml { render xml: atom_feed }
      end
    end
  end
end
