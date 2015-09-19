module Frontend
  class ConferencesController < FrontendController
    def slug
      @conferences = Conference.where(slug: params[:slug])
      return show unless @conferences
      index
    end

    def index
    end

    def show
      @conference = Conference.find_by(slug: params[:slug])
    end
  end
end
