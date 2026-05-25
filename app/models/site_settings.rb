# frozen_string_literal: true

class SiteSettings < ApplicationRecord
  DEFAULT_LOGO_URL = 'https://static.media.ccc.de/logos/voctocat-header.svg'
  DEFAULT_LOGO_ALT = 'media.ccc.de logo, a lucky cat holding a play icon'
  DEFAULT_BANNER_URL = 'https://static.media.ccc.de/media/promoted_bg.png'

  validate :promoted_banner_url_valid
  validate :live_banner_url_valid
  validate :logo_url_valid

  def self.current
    Rails.cache.fetch('site_settings/current') { first_or_create! }
  end

  after_save { Rails.cache.delete('site_settings/current') }

  def logo_alt_or_default
    logo_alt.presence || DEFAULT_LOGO_ALT
  end

  def logo_url_or_default
    logo_url.presence || DEFAULT_LOGO_URL
  end

  def promoted_banner_style
    background_image_style(promoted_banner_url.presence || DEFAULT_BANNER_URL)
  end

  def live_banner_style
    background_image_style(live_banner_url.presence || promoted_banner_url.presence || DEFAULT_BANNER_URL)
  end

  private

  def background_image_style(url)
    return nil if url.blank?

    %(background-image: url("#{url}");)
  end

  def promoted_banner_url_valid
    return if promoted_banner_url.blank?

    URI.parse(promoted_banner_url)
  rescue URI::Exception
    errors.add :promoted_banner_url, 'not a valid url'
  end

  def live_banner_url_valid
    return if live_banner_url.blank?

    URI.parse(live_banner_url)
  rescue URI::Exception
    errors.add :live_banner_url, 'not a valid url'
  end

  def logo_url_valid
    return if logo_url.blank?

    URI.parse(logo_url)
  rescue URI::Exception
    errors.add :logo_url, 'not a valid url'
  end
end
