class Api::EventsController < InheritedResources::Base
  before_filter :authenticate_api_key!
  protect_from_forgery :except => :create
  respond_to :json

  def index
    acronym = params['acronym']
    if acronym.nil?
      @events = Event.recent(25)
    else
      conference = Conference.find_by acronym: acronym
      @events = Event.find_by conference: conference
    end
    index!
  end

  def create
    acronym = params['acronym']
    conference = Conference.find_by acronym: acronym
    @event = Event.new
    @event.update_attributes(params[:event].permit([:guid, :gif_filename, :poster_filename]))
    @event.conference = conference
    @event.fill_event_info
    create!
  end

  private

  def permitted_params
    {:event => params.require(:event).permit(:guid, :gif_filename, :poster_filename)}
  end
end
