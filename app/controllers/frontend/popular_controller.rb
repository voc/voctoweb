module Frontend
  class PopularController < FrontendController
    PAGE_SIZE = 20

    def index
      @year = params[:year].to_i
      @page = params[:page].to_i || 0
      @firstyear = Frontend::Event.order('date ASC').limit(1).first.date.year
      if @year === 0
        @events = Frontend::Event.order('view_count DESC')
                                 .limit(PAGE_SIZE)
                                 .offset(@page * PAGE_SIZE)
                                 .includes(:conference)
      else
        @events = Frontend::Event.where('date between ? and ?', "#{@year}-01-01", "#{@year}-12-31")
                                 .order('view_count DESC')
                                 .limit(PAGE_SIZE)
                                 .offset(@page * PAGE_SIZE)
                                 .includes(:conference)
      end

      respond_to { |format| format.html }
    end

  end
end
