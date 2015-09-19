module Frontend
  class News < ::News
    scope :recent, ->(n) { order('date desc').limit(n) }

    def date_formatted
      date.strftime('%d.%m.%Y')
    end
  end
end
