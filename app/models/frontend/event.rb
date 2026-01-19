module Frontend
  require 'date'

  class Event < ::Event
    belongs_to :conference, class_name: 'Frontend::Conference'
    has_many :recordings, class_name: 'Frontend::Recording'

    # Frontend-specific cleaned attributes for display
    def title_clean
      self[:title].strip
    end

    def tags_clean
      self[:tags].compact.collect(&:to_s).collect(&:strip).map!(&:freeze)
    end
  end
end
