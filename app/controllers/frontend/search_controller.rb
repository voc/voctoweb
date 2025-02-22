module Frontend
  class SearchController < FrontendController
    def index
      @searchtype = ''
      @searchquery = params[:q] || params[:p]

      # reqular search by keyword
      if params[:q]
        # query the index
        result_set = Frontend::Event.query(params[:q], params[:sort])
        # paginate the results
        @events = result_set.page(params[:page]).records
      # search for a person by string
      else
        @searchtype = 'person'
        # query the index
        result_set = Frontend::Event.query_persons(params[:p], params[:sort])
        # paginate the results
        @events = result_set.page(params[:page]).records
      end

      # display the total number of found results in the view
      @number_of_results = result_set.results.total

      respond_to { |format| format.html }
    end
  end
end
