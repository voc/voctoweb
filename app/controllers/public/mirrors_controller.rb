module Public
  class MirrorsController < InheritedResources::Base
    include ApiErrorResponses
    respond_to :json
    actions :index
  end
end
