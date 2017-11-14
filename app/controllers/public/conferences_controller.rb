module Public
  class ConferencesController < InheritedResources::Base
    include ApiErrorResponses
    respond_to :json
    actions :index, :show
    
    # GET /public/conferences/54
    # GET /public/conferences/54.json
    # GET /public/conferences/31c3
    # GET /public/conferences/31c3.json
    def show
      if params[:id] =~ /\A[0-9]+\z/
        @conference = Conference.find(params[:id])
      else
        @conference = Conference.find_by(acronym: params[:id])
      end
      fail ActiveRecord::RecordNotFound unless @conference
    end
  end
end
