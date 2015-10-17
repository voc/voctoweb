module Frontend
  class TagsController < FrontendController
    def index
      @tags = Hash.new { |h, k| h[k] = [] }
      Frontend::Event.find_each do |event|
        event.tags.each { |tag| @tags[tag.strip] << event }
      end
    end

    def show
      @tag = params[:tag]
      raise ActiveRecord::NotFound unless @tag
      # TODO native postgresql query?
      @events = Frontend::Event.all.select { |event| event.tags.include? @tag }
    end
  end
end
