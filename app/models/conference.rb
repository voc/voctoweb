class Conference < ActiveRecord::Base

  scope :recent, lambda { |n| order('created_at desc').limit(n) }
end
