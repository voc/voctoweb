class Public::RecordingsController < InheritedResources::Base
  respond_to :json
  actions :index, :show
end
