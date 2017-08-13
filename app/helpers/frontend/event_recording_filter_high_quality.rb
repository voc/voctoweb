module Frontend
  class EventRecordingFilterHighQuality < EventRecordingFilter
    def filter_by_quality(recordings)
      recordings.sort {
          |recording_a,recording_b| recording_b.number_of_pixels - recording_a.number_of_pixels
      }
    end
  end
end