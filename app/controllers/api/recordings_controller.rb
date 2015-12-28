class Api::RecordingsController < Api::BaseController
  protect_from_forgery except: %i(create download)

  def index
    @recordings = Recording.recent(100)
    index!
  end

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

  def download
    event = Event.find_by! guid: params['guid']
    fail ActiveRecord::RecordNotFound if event.recordings.blank?
    respond_to do |format|
      event.recordings.each(&:start_download!)
      format.json { render json: event.recordings, status: :ok }
    end
  end

  private

  def recording_params
    params.require(:recording).permit(:original_url, :folder, :filename, :mime_type, :language, :size, :width, :height, :length)
  end

  def permitted_params
    { :event => params.require(:event).permit(:original_url, :folder, :filename, :mime_type, :language, :size, :length, :width, :height) }
  end
end
