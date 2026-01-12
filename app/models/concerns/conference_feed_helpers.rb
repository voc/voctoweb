# frozen_string_literal: true

# Feed helper methods for conferences
# Used by Feed::FolderWorker to generate per-conference feeds
module ConferenceFeedHelpers
  extend ActiveSupport::Concern

  # Get all unique MIME types used in conference recordings
  def mime_types
    recordings.pluck(:mime_type).uniq
  end

  # Yields each MIME type with its slug for feed generation
  # Returns enumerator if no block given
  def mime_type_names
    return enum_for(:mime_type_names) unless block_given?

    mime_types.map { |mime_type|
      yield mime_type.freeze, MimeType.mime_type_slug(mime_type)
    }
  end
end
