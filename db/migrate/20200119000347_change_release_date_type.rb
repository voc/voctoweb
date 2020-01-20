class ChangeReleaseDateType < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :release_date, :datetime;
    change_column :conferences, :event_last_released_at, :datetime;
  end
end
