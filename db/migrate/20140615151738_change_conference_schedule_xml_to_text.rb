class ChangeConferenceScheduleXmlToText < ActiveRecord::Migration[4.2]
  def up
    change_column :conferences, :schedule_xml, :text, limit: 10.megabyte
  end

  def down
    change_column :conferences, :schedule_xml, :binary
  end
end
