module Frontend
  class SitemapController < FrontendController
    def index
      @base_url = Settings.frontendURL
    end
  end
end
