module Public
  class ConferencesController < InheritedResources::Base
    include ApiErrorResponses
    respond_to :json
    actions :index, :show
  end
end
