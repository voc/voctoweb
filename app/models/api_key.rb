class ApiKey < ApplicationRecord

  before_create :generate_guid

  def generate_guid
    self.key = SecureRandom.uuid
  end

end
