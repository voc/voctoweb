module Frontend
  class ConferencesController < FrontendController
    SORT_PARAM = {
      'name' => 'title',
      'duration' => 'duration',
      'date' => 'release_date'
    }.freeze

    before_action :check_sort_param, only: %w(show)

    def browse
      return show if slug_matches_conference

      @folders = conferences_folder_tree_at(params[:slug] || '')
      return redirect_to browse_start_url if @folders.blank?
      respond_to do |format|
        format.html { render :browse }
      end
    end

    def show
      @conference = Frontend::Conference.find_by!(acronym: params[:acronym]) unless @conference
      @events = @conference.downloaded_events.includes(:conference).order(sort_param)
      @sorting = nil
      respond_to do |format|
        format.html { render :show }
      end
    end

    private

    def slug_matches_conference
      @conference = Frontend::Conference.find_by(slug: params[:slug])
    end

    def conferences_folder_tree_at(path)
      tree = FolderTree.new
      tree.build(conferences_with_downloaded_events)
      folders = tree.folders_at(path)
      fail ActiveRecord::RecordNotFound unless folders
      tree.sort_folders(folders)
    end

    def conferences_with_downloaded_events
      Conference.where('downloaded_events_count > 0').pluck(:id, :slug)
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
