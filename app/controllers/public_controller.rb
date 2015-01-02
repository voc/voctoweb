class PublicController < ActionController::Base
  def index
    respond_with :json
  end

  def oembed
    request.format = :json unless %w[json xml].include? request.format
    @url = params[:url]
    respond_to do |format|
      if parse_url(@url)
        format.json
        format.xml
      else
        format.json { render json: { status: :error } }
        format.xml { render xml: { status: :error } }
      end
    end
  end

  private

  def parse_url(url)
    return unless @url
    m = @url.match(%r'\Ahttp://media.ccc.de/browse/(.*)/(.*).html\z')
    return unless m
    @event = Event.by_identifier(m[1], m[2])
    return unless @event

    recording = @event.recordings.downloaded.video.first
    @width = [1280, recording.width.to_i].min
    @height = [720, recording.height.to_i].min
    @width = [@width.to_i, params[:maxwidth].to_i].min if params[:maxwidth]
    @height = [@height.to_i, params[:maxheight].to_i].min if params[:maxheight]
    true
  end
end
