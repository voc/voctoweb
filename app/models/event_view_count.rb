class EventViewCount < ApplicationRecord
  def self.updated_at
    first&.last_updated_at || Time.now
  end

  def self.touch!
    last_updated_at = first_or_create
    last_updated_at.update(last_updated_at: Time.now)
  end
end
