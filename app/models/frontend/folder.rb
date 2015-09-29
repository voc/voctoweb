module Frontend
  class Folder
    def initialize(location: nil, conference: nil)
      @location = location
      @conference = conference
    end
    attr_accessor :location, :conference

    def name
      pos = @location.rindex('/') || 0
      @location[pos..-1]
    end

    def parent
      pos = @location.rindex('/') || 0
      @location[0..pos-1]
    end

    def url
      if @conference
        "/browse/#{@conference.slug}/"
      else
        "/browse/#{@location}/"
      end
    end
  end
end
