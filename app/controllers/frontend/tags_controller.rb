module Frontend
  class TagsController < FrontendController
    def show
      @tag = params[:tag]
      raise ActiveRecord::RecordNotFound unless @tag

      # TODO native postgresql query?
      @events = Frontend::Event.all.where("? = ANY (tags)", @tag)
      respond_to { |format| format.html }
    end
  end
end
