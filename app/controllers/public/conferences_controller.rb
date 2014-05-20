class Public::ConferencesController < InheritedResources::Base
  respond_to :json
  actions :index, :show
end
