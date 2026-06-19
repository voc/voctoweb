# frozen_string_literal: true

# Presentation methods for conferences
module ConferencePresentation
  extend ActiveSupport::Concern

  class_methods do
    def has_live?
      currently_streaming.any?
    end

    def first_live
      currently_streaming.first
    end
  end

  def live
    streaming['groups'].map { |x| x['rooms'] }.flatten
  end

  def audio_recordings?
    recordings.original_language.where(mime_type: MimeType::AUDIO).exists?
  end

  def mime_types
    recordings.pluck(:mime_type).uniq
  end

  def mime_type_names
    return enum_for(:mime_type_names) unless block_given?

    mime_types.map { |mime_type|
      yield mime_type.freeze, MimeType.mime_type_slug(mime_type)
    }
  end

  def playlist(event = nil)
    return events.includes(:conference) unless event

    n = events.index(event)
    return events.includes(:conference) unless n.positive?

    events[n..-1]
  end

  def first_slug
    events.first.slug
  end
end
