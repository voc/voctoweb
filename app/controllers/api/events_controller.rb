class Api::EventsController < InheritedResources::Base
  before_filter :authenticate_api_key!
  protect_from_forgery :except => :create
  respond_to :json

  def index
    acronym = params['acronym']
    unless acronym.nil?
      conference = Conference.find_by acronym: acronym
    end
    unless conference.nil?
      @events = Event.find_by conference: conference
    else
      @events = Event.recent(25)
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
        @event.delay.download_images(params[:thumb_url],params[:gif_url], params[:poster_url])
        format.json { render json: @event, status: :created }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def download
    event = Event.find_by guid: params[:guid]
    respond_to do |format|
      if event.present?
        event.delay.download_images(params[:thumb_url],params[:gif_url], params[:poster_url])
        format.json { render json: event, status: :downloading }
      else
        format.json { render json: event, status: :unprocessable_entity }
      end
    end
  end

  private

  def create_event(params)
    return false if @event.conference.nil?  
    @event.transaction do
      @event.set_image_filenames(params[:thumb_url],params[:gif_url], params[:poster_url])
      @event.fill_event_info 
      return true if @event.save 
    end
    return false
  end

  def permitted_params
    {:event => params.require(:event).permit(:guid, :thumb_filename, :gif_filename, :poster_filename)}
  end
end
