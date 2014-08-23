class ApiKey < ActiveRecord::Base

  before_create :generate_guid

  def generate_guid
    self.key = SecureRandom.uuid
  end

end
