require 'active_support/concern'

module ThrottleConnections
  extend ActiveSupport::Concern

  def throttle?(key)
    return false if Rails.env.test?
    Rails.cache.exist?(cache_key(key))
  end

  def add_throttling(key)
    Rails.cache.write(cache_key(key), true, expires_in: 2.minute, race_condition_ttl: 5)
  end

  private

  def cache_key(key)
    ['throttle', key, Digest::MD5.hexdigest(remote_ip)]
  end

  def remote_ip
    if request.env.has_key? 'HTTP_X_FORWARDED_FOR'
      request.env['HTTP_X_FORWARDED_FOR']
    else
      request.remote_ip
    end
  end

end

