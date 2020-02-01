module Frontend
  class SearchController < FrontendController
    def index
      @searchtype = ''
      @searchquery = params[:q] || params[:p]
      if params[:q]
        @events = Frontend::Event.query(params[:q]).page(params[:page]).records
      else
        @searchtype = 'person'
        @events = Frontend::Event.query_persons(params[:p]).page(params[:page]).records
      end
      respond_to { |format| format.html }
    end
  end
end
