class Public::EventsController < InheritedResources::Base
  respond_to :json
  actions :index, :show
  skip_before_filter :verify_authenticity_token, only: :count

  def count
    @event = Event.find params[:id]
    if not @event or Rails.cache.exist?(cache_key)
      return render json: { status: :unprocessable_entity } 
    end
    
    @event.view_count += 1
    if @event.save
      Rails.cache.write(cache_key, true, expires_in: 2.minute, race_condition_ttl: 5)
      render json: { status: :ok }
    else
      render json: { status: :error }
    end
  end

  private

  def cache_key
    [@event.guid, Digest::MD5.hexdigest(remote_ip)]
  end

  def remote_ip
    if request.env.has_key? 'HTTP_X_FORWARDED_FOR'
      request.env['HTTP_X_FORWARDED_FOR']
    else
      request.remote_ip
    end
  end
end
