class Api::EventsController < Api::BaseController
  protect_from_forgery except: %i(create download update_promoted)

  def index
    acronym = params['acronym']
    conference = Conference.find_by acronym: acronym unless acronym.nil?
    unless conference.nil?
      @events = Event.find_by conference: conference
    else
      @events = Event.recent(25)
    end
    index!
  end

  def create
    acronym = params['acronym']
    conference = Conference.find_by! acronym: acronym
    @event = conference.events.build event_params

    respond_to do |format|
      if create_event(params)
        @event.download_images(params[:thumb_url], params[:poster_url])
        format.json { render json: @event, status: :created }
      else
        Rails.logger.info("JSON: failed to create event: #{@event.errors.inspect}")
        format.json { render json: @event.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  def download
    event = Event.find_by! guid: params[:guid]
    respond_to do |format|
      event.download_images(params[:thumb_url], params[:poster_url])
      format.json { render json: event, status: :ok }
    end
  end

  def update_promoted
    Event.update_promoted_from_view_count
    render json: { status: 'ok' }
  end

  def update_view_counts
    Event.update_view_counts
    render json: { status: 'ok' }
  end

  private

  def create_event(params)
    @event.transaction do
      @event.release_date = Time.now unless @event.release_date
      @event.set_image_filenames(params[:thumb_url], params[:poster_url])
      @event.fill_event_info
      return true if @event.save
    end
    false
  end

  def event_params
    params.require(:event).permit(:guid, :slug,
      :title, :subtitle, :link,
      :thumb_filename, :poster_filename,
      :conference_id,
      :description, :date,
      { persons: [] }, { tags: [] },
      :promoted, :release_date)
  end
end
