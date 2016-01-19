class Public::RecordingsController < ActionController::Base
  include ApiErrorResponses
  include ThrottleConnections
  skip_before_filter :verify_authenticity_token, only: :count
  respond_to :json

  # GET /public/recordings/1.json
  def show
    @recording = Recording.find(params[:id])
  end

  def count
    @event = Event.find(params[:event_id])
    return render json: { status: :unprocessable_entity } unless @event

    @recording = @event.recordings.find_by(filename: File.basename(params[:src]))
    if not @recording or throttle?([@recording.event_id, @recording.filename].join('/'))
      return render json: { status: :unprocessable_entity }
    end

    if @recording.recording_views.create
      add_throttling(@recording.filename)
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end
end
