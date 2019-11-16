module Public
  class ConferencesController < ActionController::Base
    include ApiErrorResponses
    respond_to :json

    # GET /public/conferences
    # GET /public/conferences.json
    def index
      key = Conference.all.maximum(:updated_at)
      @conferences = Rails.cache.fetch([:public, :conferences, key], race_condition_ttl: 10) do
        Conference.all
      end
      respond_to { |format| format.json }
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
      respond_to { |format| format.json }
    end
  end
end
