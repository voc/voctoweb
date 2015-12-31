class VideoTagSources

  def initialize(recordings, order)
    @recordings = recordings
    @order = order
  end

  def build
    useable_mime_types.map do |mime_type|
      recordings = @recordings.select { |r| r.mime_type == mime_type }
      recording = recordings.detect { |r| r.language == r.event.original_language }
      recording ||= recordings.first
    end.compact || []
  end

  private

  def useable_mime_types
    seen = {}
    available_mime_types.each do |mime_type|
      display_mime_type = MimeType.display_mime_type(mime_type)
      if seen.key?(display_mime_type)
        seen[display_mime_type] = mime_type if better?(mime_type, seen[display_mime_type])
      else
        seen[display_mime_type] = mime_type
      end
    end
    seen.values
  end

  def available_mime_types
    @recordings.map(&:mime_type).select { |mime_type| @order.include? mime_type }.uniq
  end

  def better?(new, original)
    @order.index(new) < @order.index(original)
  end
end
