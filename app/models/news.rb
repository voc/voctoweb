class News < ApplicationRecord
  scope :latest_first, ->() { order('date desc') }

  validates_presence_of :date
end
