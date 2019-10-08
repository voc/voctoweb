module Public
  class ConferencesController < InheritedResources::Base
    include ApiErrorResponses
    respond_to :json
    actions :index

    # GET /public/conferences/54
    # GET /public/conferences/54.json
    # GET /public/conferences/31c3
    # GET /public/conferences/31c3.json
    def show
      @conference = if params[:id] =~ /\A[0-9]+\z/
         Conference.find(params[:id])
      else
         Conference.find_by!(acronym: params[:id])
      end
    end
  end
end
