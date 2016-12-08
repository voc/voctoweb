module Frontend
  class PopularController < FrontendController
    def index
      @events = Frontend::Event.order('view_count DESC').limit(20).includes(:conference)

      respond_to { |format| format.html }
    end

  end
end
