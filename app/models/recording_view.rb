class RecordingView < ApplicationRecord
  validates :recording, presence: true
  belongs_to :recording

  def identifier=(val)
    secret = Rails.cache.fetch(:recording_view_secret, expires_in: 12.hours, race_condition_ttl: 10) do
      SecureRandom.random_bytes(16)
    end
    self[:identifier] = Digest::SHA1.hexdigest(val + secret)
  end
end
