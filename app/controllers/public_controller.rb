class PublicController < ActionController::Base
  include ApiErrorResponses
  respond_to :json

  def index
  end

  def oembed
    request.format = :json unless %w(json xml).include? request.format
    respond_to do |format|
      if parse_url_param
        format.json
        format.xml
      else
        format.json { render json: { status: :error } }
        format.xml { render xml: { status: :error } }
      end
    end
  end

  private

  def parse_url_param
    return unless params[:url]
    uri = URI.parse(params[:url])
    return unless allowed_url?(uri)

    @event = Event.find_by!(slug: slug_from_uri(uri))
    recording = @event.video_recordings.first
    fail ActiveRecord::RecordNotFound unless recording

    @conference = @event.conference
    @width = recording.min_width(params[:maxwidth] || view_context.aspect_ratio_width)
    @height = recording.min_height(params[:maxheight] || view_context.aspect_ratio_height)
    true
  rescue URI::InvalidURIError
    false
  end

  def allowed_url?(uri)
    return true unless Rails.env.production?
    return if uri.host != Settings.frontend_host
    return unless uri.path.starts_with?('/v/')
    true
  end

  def slug_from_uri(uri)
    uri.path[3..-1]
  end
end
