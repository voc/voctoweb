# frozen_string_literal: true

# Presentation methods for recordings
module RecordingPresentation
  extend ActiveSupport::Concern

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
