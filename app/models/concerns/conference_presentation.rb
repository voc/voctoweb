# frozen_string_literal: true

# Presentation and helper methods for conferences
# Used by frontend for streaming, navigation, and display
module ConferencePresentation
  extend ActiveSupport::Concern

  class_methods do
    # Check if any conference is currently streaming
    def has_live?
      Conference.currently_streaming.any?
    end

    # Get first currently streaming conference
    def first_live
      Conference.currently_streaming.first
    end
  end

  # Get live streaming rooms for this conference
  def live
    streaming['groups'].map { |x| x['rooms'] }.flatten
  end

  # Check if conference has audio recordings
  def audio_recordings?
    recordings.original_language.where(mime_type: MimeType::AUDIO).exists?
  end

  # Build a playlist starting from optional event
  def playlist(event = nil)
    return events.includes(:conference) unless event

    n = events.index(event)
    return events.includes(:conference) unless n.positive?

    events[n..-1]
  end

  # Get slug of first event in conference
  def first_slug
    events.first.slug
  end
end
