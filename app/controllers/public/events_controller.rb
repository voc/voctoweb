class Public::EventsController < ActionController::Base
  include ApiErrorResponses
  include Rails::Pagination
  respond_to :json

  def index
    @events = paginate(Event.all, per_page: 50, max_per_page: 256)
  end

  # GET /public/events/1
  # GET /public/events/1.json
  # GET /public/events/654331ae-1710-42e5-bdf4-65a03a80c614
  # GET /public/events/654331ae-1710-42e5-bdf4-65a03a80c614.json
  def show
    if params[:id] =~ /\A[0-9]+\z/
      @event = Event.find(params[:id])
    else
      @event = Event.find_by(guid: params[:id])
    end
    fail ActiveRecord::RecordNotFound unless @event
  end

  def search
    results = Frontend::Event.query(params[:q]).page(params[:page])
    # calling this just to set headers
    paginate(results)
    @events = results.records.includes(recordings: :conference)
    respond_to { |format| format.json }
  end
end
