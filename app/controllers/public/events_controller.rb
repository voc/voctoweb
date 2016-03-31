class Public::EventsController < ActionController::Base
  include ApiErrorResponses
  include ThrottleConnections
  respond_to :json

  def index
    events = Event.all
    paginate json: events, per_page: 50, max_per_page: 256
  end

  # GET /public/events/1.json
  def show
    @event = Event.find(params[:id])
  end

  def find
    @event = Event.find_by(guid: params[:id])
    render :show
  end
end
