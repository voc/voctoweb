module Public
  class ConferencesController < InheritedResources::Base
    include ApiErrorResponses
    include Rails::Pagination
    respond_to :json

    def index
      # stay backwards-compatible
      if params[:page] or params[:per_page]
        @conferences = paginate Conference.all
      else
        @conferences = Conference.all
      end
    end

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
