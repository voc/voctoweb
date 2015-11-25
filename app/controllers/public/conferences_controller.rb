class Public::ConferencesController < InheritedResources::Base
  include ApiErrorResponses
  respond_to :json
  actions :index, :show
end
