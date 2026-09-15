class AddScheduleToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :schedule, :jsonb, default: {}
  end
end
