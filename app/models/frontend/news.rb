module Frontend
  class News < ::News
    scope :recent, ->(n) { where("now() - date < '150 days'").order('date desc').limit(n) }

    def date_formatted
      date.strftime('%d.%m.%Y')
    end
  end
end
