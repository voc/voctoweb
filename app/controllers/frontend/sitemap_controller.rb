module Frontend
  class SitemapController < FrontendController
    def index
      @base_url = Settings.frontend_url
      respond_to { |format| format.xml }
    end
  end
end
