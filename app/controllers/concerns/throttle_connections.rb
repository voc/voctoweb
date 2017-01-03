require 'active_support/concern'

module ThrottleConnections
  extend ActiveSupport::Concern

  def throttle?(recording_view)
    return false if Rails.env.test?
    Rails.cache.exist?(cache_key(recording_view))
  end

  def add_throttling(recording_view)
    Rails.cache.write(cache_key(recording_view), true, expires_in: 12.hours, race_condition_ttl: 5)
  end

  private

  def cache_key(recording_view)
    ['throttle', recording_view.recording.event_id, recording_view.recording.filename, recording_view.identifier]
  end
end
