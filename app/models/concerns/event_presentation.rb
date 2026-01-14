# frozen_string_literal: true

# Presentation and URL generation methods for events
# Used by feeds, frontend, and other presentation layers
module EventPresentation
  extend ActiveSupport::Concern

  # Display date for event (prefers event date, falls back to release date)
  def display_date
    d = date || release_date
    d.strftime('%Y-%m-%d') if d
  end

  # URL to event thumbnail image
  # Falls back to relive thumbnail or conference logo if no thumb exists
  def thumb_url
    if thumb_filename_exists?
      File.join(Settings.static_url, conference.images_path, thumb_filename).freeze
    elsif relive_present?
      relive['thumbnail'].freeze
    else
      conference.logo_url.freeze
    end
  end

  # Check if event has relive metadata
  def relive_present?
    return unless conference.metadata['relive'].present?

    conference.metadata['relive'].any? { |r| r['guid'] == guid }
  end

  # Get relive metadata for this event
  def relive
    conference.metadata['relive']&.find { |r| r['guid'] == guid }
  end

  private

  # Helper to check if thumb filename exists
  def thumb_filename_exists?
    return if thumb_filename.blank?

    true
  end
end
