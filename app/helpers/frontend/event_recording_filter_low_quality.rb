module Frontend
  class EventRecordingFilterLowQuality < EventRecordingFilter
    def filter_by_quality(recordings)
      recordings
        .select { |recording| recording.height && recording.height.to_i < 720 }
        .sort { |recording_a,recording_b| recording_b.number_of_pixels - recording_a.number_of_pixels }
    end
  end
end