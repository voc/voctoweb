module Frontend
  class ConferencesController < FrontendController
    SORT_PARAM = {
      'name' => 'title',
      'duration' => 'duration',
      'date' => 'release_date'
    }.freeze

    before_action :check_sort_param, only: %w(slug show)

    def slug
      @conference = Frontend::Conference.find_by(slug: params[:slug])
      return show if @conference
      index
    end

    def index
      @folders = conferences_folder_tree_at(params[:slug] || '')
      return redirect_to browse_start_url if @folders.blank?
      render :index
    end

    def show
      @events = @conference.events.order(sort_param)
      @sorting = nil
      render :show
    end

    private

    def conferences_folder_tree_at(path)
      tree = FolderTree.new
      tree.build(Conference.pluck(:id, :slug))
      tree.sort_folders(tree.folders_at(path))
    end

    def sort_param
      return SORT_PARAM[@sorting] if @sorting
      'title'
    end

    def check_sort_param
      return unless params[:sort]
      return unless SORT_PARAM.keys.include?(params[:sort])
      @sorting = params[:sort]
    end
  end
end
