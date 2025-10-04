module Frontend
  class ConferencesController < FrontendController
    SORT_PARAM = {
      'name' => 'title',
      'duration' => 'duration',
      'date' => 'date desc, release_date desc',
      'view_count' => 'view_count desc'
    }.freeze

    before_action :check_sort_param, only: %w(show)

    def all
      @conferences = conferences_with_events.order('event_last_released_at DESC')
      respond_to do |format|
        format.html { render :list }
      end
    end

    def browse
      return show if slug_matches_conference

      @folders = conferences_folder_tree_at(params[:slug] || '')
      return redirect_to root_url if @folders.blank?

      respond_to do |format|
        format.html { render :browse }
      end
    end

    def show
      @conference = Frontend::Conference.find_by!(acronym: params[:acronym]) unless @conference
      if params[:tag]
        @tag = params[:tag]
        @events = @conference.events.includes(:conference).reorder(sort_param).select { |event| event.tags.include? @tag }
      else
        @events = @conference.events.includes(:conference).reorder(sort_param)
      end

      respond_to do |format|
        format.html { render :show }
        format.activity_json do
          render json: @conference, serializer: ActivityPub::ConferenceSerializer, content_type: 'application/activity+json'
        end
      end
    end

    private

    def slug_matches_conference
      @conference = Frontend::Conference.find_by(slug: params[:slug])
    end

    def conferences_folder_tree_at(path)
      tree = FolderTree.new
      tree.build(conferences_with_events.pluck(:id, :slug))
      folders = tree.folders_at(path)
      fail ActiveRecord::RecordNotFound unless folders

      tree.sort_folders(folders)
    end

    def conferences_with_events
      Conference.where('downloaded_events_count > 0')
    end

    def sort_param
      return SORT_PARAM[@sorting] if @sorting

      'view_count desc'
    end

    def check_sort_param
      return unless params[:sort]
      return unless SORT_PARAM.keys.include?(params[:sort])

      @sorting = params[:sort]
    end
  end
end
