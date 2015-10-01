module Frontend
  class NewsController < FrontendController
    def index
      news = News.all
      atom_feed = ::Feeds::NewsFeedGenerator.generate(news, options: {
        author: Settings.feeds['channel_owner'],
        about: 'http://media.ccc.de/',
        title: 'CCC TV - NEWS',
        feed_url: 'http://media.ccc.de/news.atom',
        icon: 'http://media.ccc.de/favicons.ico',
        logo: 'http://media.ccc.de/images/tv.png'
      })
      render text: atom_feed
    end
  end
end
