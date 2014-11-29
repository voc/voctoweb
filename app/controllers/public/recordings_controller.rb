class Public::RecordingsController < InheritedResources::Base
  include ThrottleConnections
  respond_to :json
  actions :index, :show
  skip_before_filter :verify_authenticity_token, only: :count

  def count
    @event = Event.find params[:event_id]
    if not @event
      return render json: { status: :unprocessable_entity }
    end

    @recording = @event.recordings.where(filename: File.basename(params[:src])).first
    if not @recording or throttle?(@recording.filename)
      return render json: { status: :unprocessable_entity }
    end

    if @recording.recording_views.create
      add_throttling(@recording.filename)
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end

  protected

  def collection
    get_collection_ivar || set_collection_ivar(Recording.includes(:event).includes(event: :conference))
  end
end
