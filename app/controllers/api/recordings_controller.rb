class Api::RecordingsController < ApiController
  protect_from_forgery except: %i(create download)
  before_action :set_recording, only: [:show, :edit, :update, :destroy]

  # GET /api/recordings/
  def index
    @recordings = Recording.recent(100)
  end

  # GET /api/recordings/1
  def show
  end

  # GET /api/recordings/new
  def new
    @conference = Recording.new
  end

  # GET /api/recordings/1/edit
  def edit
  end

  # POST /api/recordings/
  def create
    event = Event.find_by! guid: params['guid']

    @recording = Recording.new(recording_params)
    @recording.event = event

    respond_to do |format|
      if @recording.save
        format.json { render :show, status: :created }
      else
        if @recording.dupe.present?
          @recording = @recording.dupe[0]
          
          if @recording.update(recording_params)
            format.json { render :show, status: :ok }
          else
            format.json { render :show, status: :unprocessable_entity }
          end
        else
          Rails.logger.info("JSON: failed to create recording: #{@recording.errors.inspect}")
          format.json { render json: @recording.errors.messages, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /api/recordings/1
  def update
    fail ActiveRecord::RecordNotFound unless @recording

    respond_to do |format|
      if @recording.update(recording_params)
        format.json { render :show, status: :ok }
      else
        format.json { render :show, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/recordings/1
  def destroy
    @recording.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_recording
    @recording = Recording.includes([:conference]).find(params[:id])
  end

  def recording_params
    params.require(:recording).permit(:folder, :filename, :mime_type, :language, :high_quality, :html5, :size, :width, :height, :length, :state)
  end
end
