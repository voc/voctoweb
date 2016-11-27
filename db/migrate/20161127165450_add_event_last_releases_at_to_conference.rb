class AddEventLastReleasesAtToConference < ActiveRecord::Migration[5.0]
  def change
    add_column :conferences, :event_last_released_at, :date, null: true
  end
end
