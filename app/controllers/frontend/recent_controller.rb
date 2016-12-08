module Frontend
  class RecentController < FrontendController
    def index
      @events = Frontend::Event.recent(20).includes(:conference)

      respond_to { |format| format.html }
    end

  end
end
