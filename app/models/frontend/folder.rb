module Frontend
  class Folder
    def initialize(location: nil, conference: nil)
      @location = location
      @conference = conference
    end
    attr_accessor :location, :conference

    def name
      pos = @location.rindex('/') + 1 || 0
      @location[pos..-1]
    end

    def parent
      pos = @location.rindex('/') || 0
      @location[0..pos-1]
    end

    def url
      "/browse/#{@location}/index.html"
    end
  end
end
