module Frontend
  class PopularController < FrontendController
    PAGE_SIZE = 20

    def index
      @year = params[:year].to_i.to_s
      @page = params[:page].to_i || 0
      @firstyear = Frontend::Event
        .select('date_part(\'year\',min(date)) as firstyear, -1 AS guid')
        .take['firstyear'].to_i
      if @year == "0"
        @events = Frontend::Event
          .order('view_count DESC')
          .limit(PAGE_SIZE)
          .offset(@page * PAGE_SIZE)
          .includes(:conference)
      else
        @events = Frontend::Event
          .where('date_part(\'year\', date) = ?', @year )
          .order('view_count DESC')
          .limit(PAGE_SIZE)
          .offset(@page * PAGE_SIZE)
          .includes(:conference)
      end

      respond_to { |format| format.html }
    end

  end
end
