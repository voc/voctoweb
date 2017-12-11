class AddDownloadedEventsCountToConferences < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :downloaded_events_count, :integer, default: 0, null: false
    Conference.reset_column_information
    Conference.find_each do |c|
      c.update_column :downloaded_events_count, Event.recorded_at(c).to_a.size
    end
  end
end
