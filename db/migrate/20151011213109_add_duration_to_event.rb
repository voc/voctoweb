class AddDurationToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :duration, :integer, default: 0
    Event.find_each do |event|
      recordings = event.recordings
      next unless recordings.present?
      recording = recordings.find { |r| r.length.present? }
      next unless recording
      event.update(duration: recording.length)
    end
  end
end
