module Frontend
  class ConferencesController < FrontendController
    def slug
      @conferences = Conference.where(slug: params[:slug])
      return show unless @conferences
      index
    end

    def index
      @folders = FolderList.new(params[:slug] || '').folders
      render :index
    end

    def show
      @sorting = nil
      @conference = Conference.find_by(slug: params[:slug])
      render :show
    end
  end
end
