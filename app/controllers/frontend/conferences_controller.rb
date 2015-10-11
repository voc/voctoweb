module Frontend
  class ConferencesController < FrontendController
    def slug
      @conference = Frontend::Conference.find_by(slug: params[:slug])
      return show if @conference
      index
    end

    def index
      @folders = FolderList.new(params[:slug] || '').folders
      return redirect_to browse_start_url if @folders.blank?
      render :index
    end

    def show
      @events = @conference.events
      @sorting = nil
      render :show
    end
  end
end
