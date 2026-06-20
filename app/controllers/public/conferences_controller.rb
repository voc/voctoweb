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
    #
    # Optional filters: ?url_contains=foo matches against the conference's own
    # website (the `link` field), ?currently_streaming=true restricts to
    # conferences currently live.
    def index
      include_empty = ActiveModel::Type::Boolean.new.cast(params[:include_empty])
      currently_streaming = ActiveModel::Type::Boolean.new.cast(params[:currently_streaming])
      conferences = include_empty ? Conference.all : Conference.with_recorded_events
      conferences = conferences.where('link LIKE ?', "%#{params[:url_contains]}%") if params[:url_contains].present?
      conferences = conferences.merge(Conference.currently_streaming) if currently_streaming

      # The listed set can change without any conference row changing: recording
      # an event updates downloaded_events_count via update_column, which skips
      # updated_at. cache_key_with_version's count+max(updated_at) version string
      # (microsecond precision) busts the cache when a conference gains or loses
      # events, unlike a plain Time, whose to_param truncates to whole seconds
      # and could collide with another request's key; include_empty/the filters
      # keep the variants cached separately.
      key = [:public, :conferences, include_empty, params[:url_contains], currently_streaming, conferences.cache_key_with_version]
      @conferences = Rails.cache.fetch(key, race_condition_ttl: 10) do
        conferences.to_a
      end
      respond_to { |format| format.json }
    end

    # GET /public/conferences/recent
    # GET /public/conferences/recent.json?limit=5
    def recent
      limit = (params[:limit] || 5).to_i.clamp(1, 30)
      @conferences = Conference.with_recent_events(limit)
      respond_to { |format| format.json { render :index } }
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
