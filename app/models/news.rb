class News < ActiveRecord::Base
  validates_presence_of :date
end
