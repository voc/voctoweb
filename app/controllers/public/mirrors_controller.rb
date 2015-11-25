class Public::MirrorsController < InheritedResources::Base
  include ApiErrorResponses
  respond_to :json
  actions :index
end
