class RecordingView < ApplicationRecord
  validates_presence_of :recording
  belongs_to :recording
end
