class ApiKey < ApplicationRecord

  before_create :generate_guid

  def generate_guid
    self.key = SecureRandom.uuid
  end

  # keep this in sync with filters in app/admin
  def self.ransackable_attributes(*)
    %w[key description]
  end

  def self.ransackable_associations(*)
    []
  end

end
