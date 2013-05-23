class EventInfo < ActiveRecord::Base
  belongs_to :event
  serialize :persons, Array
  serialize :tags, Array
end
