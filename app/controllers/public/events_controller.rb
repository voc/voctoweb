class Public::EventsController < InheritedResources::Base
  include ApiErrorResponses
  respond_to :json
  actions :index, :show

  protected

  def collection
    get_collection_ivar || set_collection_ivar(Event.includes(:conference).includes(:recordings))
  end
end
