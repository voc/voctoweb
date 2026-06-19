class News < ApplicationRecord
  scope :latest_first, ->() { order('date desc') }
  scope :recent, ->(n) { where("now() - date < '150 days'").order('date desc').limit(n) }

  validates_presence_of :date

  def date_formatted
    date.strftime('%d.%m.%Y')
  end
end
