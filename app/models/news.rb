class News < ActiveRecord::Base
  scope :recent, ->(n) { order('date desc').limit(n) }
  validates_presence_of :date

  def date_formatted
    self.date.strftime("%d.%m.%Y")
  end
end
