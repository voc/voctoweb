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
    @event.guid = params[:guid]
    @event.conference = conference

    respond_to do |format|
      if create_event(params)
        @event.delay.download_images(params[:gif_url], params[:poster_url])
        format.json { render json: @event, status: :created }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def create_event(params)
    return false if @event.conference.nil?  
    @event.transaction do
      @event.set_image_filenames(params[:gif_url], params[:poster_url])
      @event.fill_event_info 
      @event.save 
      return true
    end
    return false
  end

  def permitted_params
    {:event => params.require(:event).permit(:guid, :gif_filename, :poster_filename)}
  end
end
