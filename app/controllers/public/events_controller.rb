class Public::EventsController < InheritedResources::Base
  include ThrottleConnections
  respond_to :json
  actions :index, :show
  skip_before_filter :verify_authenticity_token, only: :count

  def count
    @event = Event.find params[:id]
    if not @event or throttle?(@event.guid)
      return render json: { status: :unprocessable_entity } 
    end
    
    @event.view_count += 1
    if @event.save
      add_throttling(@event.guid)
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end

  private

end
