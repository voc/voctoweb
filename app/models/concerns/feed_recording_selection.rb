# frozen_string_literal: true

# Feed recording selection logic for generating RSS/Podcast feeds
# Used by Feed::* workers to select appropriate recordings based on quality and MIME type
module FeedRecordingSelection
  extend ActiveSupport::Concern

  # Main entry point: selects recording based on quality and MIME type
  def recording_for_feed_with_quality(quality: nil, mime_type: nil)
    case quality&.downcase
    when FeedQuality::HQ then recording_for_hq_feed(mime_type: mime_type)
    when FeedQuality::LQ then recording_for_lq_feed(mime_type: mime_type)
    when FeedQuality::MASTER then recording_for_master_feed(mime_type: mime_type)
    else recording_for_feed(mime_type: mime_type)
    end
  end

  # Default feed: no quality filter, just select by MIME type preference
  # Used for audio-only feeds and when no quality is specified
  def recording_for_feed(mime_type: nil)
    recs = base_feed_recordings(mime_type)
    return nil if recs.empty?

    if mime_type
      recs.first
    else
      recs.min_by { |r| MimeType::PREFERRED_VIDEO.index(r.mime_type) || 999 }
    end
  end

  # High Quality feed: selects highest resolution recording
  def recording_for_hq_feed(mime_type: nil)
    recs = base_feed_recordings(mime_type)
    return nil if recs.empty?

    if mime_type
      recs.max_by { |r| r.number_of_pixels }
    else
      recs.min_by { |r| [MimeType::PREFERRED_VIDEO.index(r.mime_type) || 999, -r.number_of_pixels] }
    end
  end

  # Low Quality feed: selects highest resolution recording under 720p
  def recording_for_lq_feed(mime_type: nil)
    recs = base_feed_recordings(mime_type)
    return nil if recs.empty?

    under_720p = recs.select { |r| r.height && r.height.to_i < 720 }
    return nil if under_720p.empty?

    if mime_type
      under_720p.max_by { |r| r.number_of_pixels }
    else
      under_720p.min_by { |r| [MimeType::PREFERRED_VIDEO.index(r.mime_type) || 999, -r.number_of_pixels] }
    end
  end

  # Master feed: prefers multi-language recordings, then highest resolution
  def recording_for_master_feed(mime_type: nil)
    recs = base_feed_recordings(mime_type)
    return nil if recs.empty?

    if mime_type
      recs.max_by { |r| [r.language.length, r.number_of_pixels] }
    else
      recs.min_by { |r| [MimeType::PREFERRED_VIDEO.index(r.mime_type) || 999, -r.language.length, -r.number_of_pixels] }
    end
  end

  # Selects preferred video recording based on MIME type preference order
  # Used by legacy feed workers and RDF generator
  def preferred_recording(order: MimeType::PREFERRED_VIDEO)
    video_recordings = recordings.html5.video
    return if video_recordings.empty?

    seen = Hash[video_recordings.map { |r| [r.mime_type, r] }]
    order.each { |mt| return seen[mt] if seen.key?(mt) }
    seen.first[1]
  end

  # Selects preferred audio recording in original language
  # Used by audio feed workers
  def audio_recording
    audio_recordings = recordings.original_language.where(mime_type: MimeType::AUDIO)
    return if audio_recordings.empty?

    seen = Hash[audio_recordings.map { |r| [r.mime_type, r] }]
    MimeType::AUDIO.each { |mt| return seen[mt] if seen.key?(mt) }
    seen.first[1]
  end

  private

  # Get base recordings for feed: non-translated videos/audio without slides
  def base_feed_recordings(mime_type)
    recs = recordings.where(translated: false)

    if mime_type
      # If specific MIME type requested, filter by it
      if MimeType.is_video(mime_type)
        recs.without_slides.by_mime_type(mime_type)
      else
        recs.by_mime_type(mime_type)
      end
    else
      # Otherwise get all videos (excluding slides)
      recs.video_without_slides
    end
  end
end
