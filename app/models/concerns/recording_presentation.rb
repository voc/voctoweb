# frozen_string_literal: true

# Presentation methods for recordings
# Used by frontend for display
module RecordingPresentation
  extend ActiveSupport::Concern

  # Get display resolution label based on height
  def resolution
    return '' unless height

    if height < 720
      'sd'
    elsif height < 1080
      'hd'
    elsif height < 1716
      'full-hd'
    else
      '4k'
    end
  end
end
