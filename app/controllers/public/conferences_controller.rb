module Public
  class ConferencesController < ActionController::Base
    include ApiErrorResponses
    respond_to :json

    # GET /public/conferences
    # GET /public/conferences.json
    #
    # By default only conferences that have at least one recorded event are
    # returned (matching what the web frontend shows). Pass ?include_empty=true
    # to also include conferences without any associated events.
    def index
      include_empty = ActiveModel::Type::Boolean.new.cast(params[:include_empty])
      conferences = include_empty ? Conference.all : Conference.with_recorded_events

      # The listed set can change without any conference row changing: recording
      # an event updates downloaded_events_count via update_column, which skips
      # updated_at. The result count busts the cache when a conference gains or
      # loses events; include_empty keeps the two variants cached separately.
      key = [:public, :conferences, include_empty, conferences.maximum(:updated_at), conferences.count]
      @conferences = Rails.cache.fetch(key, race_condition_ttl: 10) do
        conferences.to_a
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
