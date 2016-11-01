class Public::RecordingsController < ActionController::Base
  include ApiErrorResponses
  include ThrottleConnections
  respond_to :json

  def index
    recordings = Recording.all
    paginate json: recordings, per_page: 50, max_per_page: 256
  end

  # GET /public/recordings/1.json
  def show
    @recording = Recording.find(params[:id])
  end

  def count
    @event = Event.find(params[:event_id])
    return render json: { status: :unprocessable_entity } unless @event

    @recording = @event.recordings.find_by(filename: File.basename(params[:src]))
    if not @recording or throttle?(key(@recording))
      return render json: { status: :unprocessable_entity }
    end

    if @recording.recording_views.create
      add_throttling(key(@recording))
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end

  private

  def key(recording)
    [@recording.event_id, @recording.filename].join('/')
  end
end
