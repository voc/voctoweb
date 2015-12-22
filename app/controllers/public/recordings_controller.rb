module Public
  class RecordingsController < InheritedResources::Base
    include ApiErrorResponses
    include ThrottleConnections
    respond_to :json
    actions :index, :show
    skip_before_filter :verify_authenticity_token, only: :count

    def count
      @event = Event.find params[:event_id]
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

    protected

    def collection
      get_collection_ivar || set_collection_ivar(Recording.includes(:event).includes(event: :conference))
    end
  end
end
