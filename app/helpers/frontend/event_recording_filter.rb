module Frontend
  class EventRecordingFilter
    def self.by_quality_string(quality)
      if nil == quality || quality.empty?
        return EventRecordingFilter.new
      end

      case quality.upcase
        when 'HQ' then EventRecordingFilterHighQuality.new
        when 'LQ' then EventRecordingFilterLowQuality.new
        else raise ArgumentError, "Invalid quality argument"
      end
    end

    @target_mime_type = nil

    def with_mime_type(mime_type)
      @target_mime_type = mime_type
      self
    end

    def filter(event)
      if @target_mime_type
        @recordings = event.recordings.by_mime_type(@target_mime_type)
      else
        @recordings = event.recordings.video
      end

      @recordings = filter_by_quality(@recordings)

      return if @recordings.empty?

      if @target_mime_type != nil
        @recordings.first.freeze
      else
        select_first_video_with_preferred_mime_type().freeze
      end
    end

    private

    def filter_by_quality(recordings)
      recordings
    end

    def select_first_video_with_preferred_mime_type()
      MimeType::PREFERRED_VIDEO.each { |mime_type|
        found = @recordings.find { |recording| recording.mime_type == mime_type }
        return found if found != nil
      }
      @recordings.first
    end
  end
end