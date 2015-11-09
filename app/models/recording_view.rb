class RecordingView < ActiveRecord::Base
  validates_presence_of :recording
  belongs_to :recording
end
