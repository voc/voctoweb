class Api::RecordingsController < InheritedResources::Base
  before_filter :deny_json_request, if: :ssl_configured?
  before_filter :authenticate_api_key!
  protect_from_forgery except: %i[create download]
  respond_to :json

  def index
    @recordings = Recording.recent(100)
    index!
  end

  def create
    event = Event.find_by guid: params['guid']
    @recording = Recording.new(params[:recording].permit([:original_url, :folder, :filename, :mime_type, :size, :width, :height, :length]))
    @recording.event = event

    respond_to do |format|
      if @recording.validate_for_api and @recording.save
        @recording.start_download
        format.json { render json: @recording, status: :created }
      else
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  def download
    event = Event.find_by guid: params['guid']
    respond_to do |format|
      if event.present? and event.recordings.any?
        event.recordings.each { |r| r.start_download }
        format.json { render json: event.recordings, status: :downloading }
      else
        format.json { render json: event, status: :unprocessable_entity }
      end
    end
  end

  private

  def permitted_params
    {:event => params.require(:event).permit(:original_url, :folder, :filename, :mime_type, :size, :length, :width, :height)}
  end

end
