module Frontend
  class TagsController < FrontendController
    def show
      @tag = params[:tag]
      raise ActiveRecord::RecordNotFound unless @tag

      @events = Event.where("? = ANY (tags)", @tag)
      respond_to { |format| format.html }
    end
  end
end
