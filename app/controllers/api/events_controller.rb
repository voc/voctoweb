class Api::EventsController < ApiController
  protect_from_forgery except: %i(create update_promoted)
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # POST /api/events.json
  def index
    @events = Event.all
  end

  # GET /api/events/1.json
  # GET /api/events/654331ae-1710-42e5-bdf4-65a03a80c614.json
  def show
  end

  # GET /api/events/new
  def new
    @event = Event.new
  end

  # GET /api/events/1/edit
  # GET /api/events/654331ae-1710-42e5-bdf4-65a03a80c614/edit
  def edit
  end

  # POST /api/events.json
  def create
    acronym = params['acronym']
    conference = Conference.find_by! acronym: acronym
    @event = conference.events.build event_params

    respond_to do |format|
      if create_event(params)
        format.json { render json: @event, status: :created }
      else
        Rails.logger.info("JSON: failed to create event: #{@event.errors.inspect}")
        format.json { render json: @event.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/events/1.json
  # PATCH/PUT /api/events/654331ae-1710-42e5-bdf4-65a03a80c614.json
  def update
    fail ActiveRecord::RecordNotFound unless @event

    respond_to do |format|
      if @event.update(event_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/events/1.json
  # DELETE /api/events/654331ae-1710-42e5-bdf4-65a03a80c614.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def update_feeds
    Feed::PodcastWorker.perform_async
    Feed::LegacyWorker.perform_async
    Feed::AudioWorker.perform_async
    Feed::ArchiveWorker.perform_async
    Feed::ArchiveLegacyWorker.perform_async
    render json: { status: 'ok' }
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

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    if params[:id] =~ /\A[0-9]+\z/
      @event = Event.find(params[:id])
    else
      @event = Event.find_by(guid: params[:id])
    end
  end

  def create_event(params)
    @event.set_image_filenames(params[:thumb_url], params[:poster_url], params[:timeline_url], params[:thumbnails_url])
    @event.save!
  rescue ActiveRecord::RecordInvalid
    false
  end

  def event_params
    params.require(:event).permit(:guid, :slug,
      :title, :subtitle, :link,
      :original_language,
      :thumb_filename, :poster_filename, :timeline_filename, :thumbnails_filename,
      :conference_id,
      :metadata,
      :description, :date,
      :doi,
      { persons: [] }, { tags: [] },
      :promoted, :release_date)
  end
end
