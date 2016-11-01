require 'active_support/concern'

module Recent
  extend ActiveSupport::Concern

  included do
    scope :recent, ->(n) { order('created_at desc').limit(n) }
  end
end
