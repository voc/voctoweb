class AddScheduleUrlToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :schedule_url, :string
    add_column :conferences, :schedule_xml, :binary
    add_column :conferences, :schedule_state, :string, default: "not_present", null: false
  end
end
