class Public::RecordingsController < ActionController::Base
  include ApiErrorResponses
  include Rails::Pagination
  include ThrottleConnections
  skip_forgery_protection
  respond_to :json

  def index
    @recordings = paginate(Recording.all.includes(:event, :conference), per_page: 50, max_per_page: 256)
  end

  # GET /public/recordings/1.json
  def show
    @recording = Recording.find(params[:id])
  end

  def count
    @event = Event.find(params[:event_id])
    @recording = @event.recordings.find_by!(filename: File.basename(params[:src]))
    recording_view = @recording.recording_views.build(identifier: remote_ip, user_agent: request.user_agent)

    return render json: { status: :unprocessable_entity } if throttle?(recording_view)

    if recording_view.save
      add_throttling(recording_view)
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end

  private

  def remote_ip
    if request.env.key? 'HTTP_X_FORWARDED_FOR'
      request.env['HTTP_X_FORWARDED_FOR']
    else
      request.remote_ip
    end
  end
end
