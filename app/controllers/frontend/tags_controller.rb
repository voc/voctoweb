module Frontend
  class TagsController < FrontendController
    def index
      @tag = ''
    end

    def show
      @tag = ''
      @events = []
    end
  end
end
