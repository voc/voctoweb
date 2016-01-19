class Api::RecordingsController < ApiController
  protect_from_forgery except: %i(create download)
  before_action :set_recording, only: [:show, :edit, :update, :destroy]

  # GET /api/recordings.json
  def index
    @recordings = Recording.recent(100)
  end

  # GET /api/recordings/1.json
  def show
  end

  # GET /api/recordings/new
  def new
    @conference = Recording.new
  end

  # GET /api/recordings/1/edit
  def edit
  end

  # POST /api/recordings.json
  def create
    event = Event.find_by! guid: params['guid']
    @recording = Recording.new(recording_params)
    @recording.event = event

    respond_to do |format|
      if @recording.valid? and @recording.validate_for_api and @recording.save
        @recording.start_download!
        format.json { render json: @recording, status: :created }
      else
        Rails.logger.info("JSON: failed to create recording: #{@recording.errors.inspect}")
        format.json { render json: @recording.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/recordings/1.json
  def update
    respond_to do |format|
      if @recording.update(recording_params)
        format.json { render :show, status: :ok, location: @recording }
      else
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/recordings/1.json
  def destroy
    @recording.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def download
    event = Event.find_by! guid: params['guid']
    fail ActiveRecord::RecordNotFound if event.recordings.blank?
    respond_to do |format|
      event.recordings.each(&:start_download!)
      format.json { render json: event.recordings, status: :ok }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_recording
    @recording = Recording.find(params[:id])
  end

  def recording_params
    params.require(:recording).permit(:original_url, :folder, :filename, :mime_type, :language, :hd_quality, :html5, :size, :width, :height, :length)
  end
end
