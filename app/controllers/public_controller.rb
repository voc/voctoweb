class PublicController < ActionController::Base
  respond_to :json
  def index
  end

  def oembed
    @url = params[:url]
    return render json: { status: :error } unless @url
    m = @url.match(%r'\Ahttp://media.ccc.de/browse/(.*)/(.*).html\z')
    return render json: { status: :error } unless m
    @event = Event.by_identifier(m[1], m[2])
    return render json: { status: :error } unless @event

    recording = @event.recordings.downloaded.video.first
    @width = recording.width
    @height = recording.height
    @width = [1280, @width, params[:maxwidth].to_i].min if params[:maxwidth]
    @height = [720, @height, params[:maxheight].to_i].min if params[:maxheight]
  end
end
