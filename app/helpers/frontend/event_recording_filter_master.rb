module Frontend
  class EventRecordingFilterMaster < EventRecordingFilter
    def filter_by_quality(recordings)
      recordings
        .sort { |recording_a,recording_b| recording_b.number_of_pixels - recording_a.number_of_pixels }
        .sort { |recording_a,recording_b| recording_b.language.length - recording_b.language.length }
        .select { |recording| recording.slides? != true }
    end
  end
end
