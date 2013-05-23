class Api::RecordingsController < InheritedResources::Base
  before_filter :authenticate_api_key!
  protect_from_forgery :except => :create
  respond_to :json

  def index
    @recordings = Recording.recent(100)
    index!
  end

  def create
    event = Event.find_by guid: params['guid']
    @recording = Recording.new
    @recording.update_attributes(params[:recording].permit([:original_url, :filename, :mime_type, :size, :length]))
    if @recording.original_url.nil?
      return
    end
    @recording.event = event

    respond_to do |format|
      if @recording.save
        @recording.start_download
        format.json { render json: @recording, status: :created }
      else
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def permitted_params
    {:event => params.require(:event).permit(:original_url, :filename, :mime_type, :size, :length)}
  end

end
