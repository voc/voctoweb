class Api::ConferencesController < ApiController
  protect_from_forgery except: %i(create)
  before_action :set_conference, only: [:show, :edit, :update, :destroy]

  # GET /api/conferences.json
  def index
    @conferences = Conference.all
  end

  # GET /api/conferences/1.json
  def show
  end

  # GET /api/conferences/new
  def new
    @conference = Conference.new
  end

  # GET /api/conferences/1/edit
  def edit
  end

  # POST /api/conferences.json
  def create
    @conference = Conference.new(conference_params)

    respond_to do |format|
      if @conference.schedule_url && @conference.save
        @conference.url_changed!
        format.json { render json: @conference, status: :created }
      else
        Rails.logger.info("JSON: failed to create conference: #{@conference.errors.inspect}")
        format.json { render json: @conference.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/conferences/1.json
  def update
    fail ActiveRecord::RecordNotFound unless @conference

    respond_to do |format|
      if @conference.update(conference_params)
        format.json { render :show, status: :ok }
      else
        format.json { render json: @conference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/conferences/1.json
  def destroy
    @conference.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_conference
    @conference = Conference.find(params[:id])
  end

  def conference_params
    params.require(:conference).permit(:acronym, :schedule_url, :recordings_path, :images_path, :metadata, :slug, :aspect_ratio, :logo, :title)
  end
end
