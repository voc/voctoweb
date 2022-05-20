module Frontend
  class UnpopularController < FrontendController
    PAGE_SIZE = 50

    def index
      @year = params[:year].to_i
      @page = params[:page].to_i || 0
      @firstyear = Frontend::Event.order('date ASC').limit(1).first.date.year
      @events = if @year.zero?
                  Frontend::Event.order('view_count ASC')
                                 .limit(PAGE_SIZE)
                                 .offset(@page * PAGE_SIZE)
                                 .includes(:conference)
                else
                  Frontend::Event.unpopular(@year)
                                 .limit(PAGE_SIZE)
                                 .offset(@page * PAGE_SIZE)
                                 .includes(:conference)
                end

      respond_to { |format| format.html }
    end
  end
end
