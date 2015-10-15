module Frontend
  class SitemapController < FrontendController
    def index
      @base_url = Settings.frontend_url
    end
  end
end
