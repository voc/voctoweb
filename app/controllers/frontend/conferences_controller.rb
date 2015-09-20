module Frontend
  class ConferencesController < FrontendController
    def slug
      @conferences = Conference.where(slug: params[:slug])
      return show unless @conferences
      index
    end

    def index
      @folders = []
    end

    def show
      @sorting = nil
      @conference = Conference.find_by(slug: params[:slug])
    end
  end
end
