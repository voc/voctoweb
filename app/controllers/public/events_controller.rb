class Public::EventsController < ActionController::Base
  include ApiErrorResponses
  include Rails::Pagination
  respond_to :json

  # GET /public/events
  # GET /public/events.json
  def index
    @events = paginate(Event.all.includes(:conference), per_page: 50, max_per_page: 256)
    respond_to { |format| format.json }
  end

  # GET /public/events/recent
  # GET /public/events/recent.json
  def recent
    @events = paginate(Event.includes(:conference).released, per_page: 100, max_per_page: 256)
    respond_to { |format| format.json { render :index } }
  end

  # GET /public/events/promoted
  # GET /public/events/promoted.json
  def promoted
    @events = Event.includes(:conference).promoted(100)
    respond_to { |format| format.json { render :index } }
  end

  # GET /public/events/popular?year=2020
  def popular
    @events = paginate(Event.includes(:conference).popular(params[:year] || Time.current.year), per_page: 50, max_per_page: 256)
    respond_to { |format| format.json { render :index } }
  end

  # GET /public/events/unpopular?year=2020
  def unpopular
    @events = paginate(Event.includes(:conference).unpopular(params[:year] || Time.current.year), per_page: 50, max_per_page: 256)
    respond_to { |format| format.json { render :index } }
  end

  # GET /public/events/1
  # GET /public/events/1.json
  # GET /public/events/654331ae-1710-42e5-bdf4-65a03a80c614
  # GET /public/events/654331ae-1710-42e5-bdf4-65a03a80c614.json
  def show
    if params[:id] =~ /\A[0-9]+\z/
      @event = Event
        .includes(recordings: :conference)
        .find(params[:id])
    else
      @event = Event
        .where(guid: params[:id])
        .or(Event.where(slug: params[:id]))
        .includes(recordings: :conference)
        .take
    end

    fail ActiveRecord::RecordNotFound unless @event

    respond_to { |format| format.json }
  end

  # GET /public/events/search?q=foo&page=1&per_page=25
  def search
    per_page = (params[:per_page] || 25).to_i.clamp(1, 256)
    results = Event.query(params[:q]).page(params[:page]).per(per_page)
    # calling this just to set headers
    paginate(results, per_page: per_page)
    @events = results.records.includes(recordings: :conference)
    respond_to { |format| format.json }
  end
end
