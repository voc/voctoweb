class AddDownloadedRecordingsCounterOnEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :downloaded_recordings_count, :integer, default: 0
    Event.reset_column_information
    Event.find_each do |e|
      e.update downloaded_recordings_count: e.downloaded_recordings.count
    end
  end
end
