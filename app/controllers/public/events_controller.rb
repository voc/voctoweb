class Public::EventsController < ActionController::Base
  include ApiErrorResponses
  include Rails::Pagination
  respond_to :json

  def index
    @events = paginate Event.all.includes(:conference)
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
  end

  def search
    @events = paginate(Frontend::Event.query(params[:q]))
      .records
      .includes(recordings: :conference)
  end
end
