class ChangeConferenceScheduleXmlToText < ActiveRecord::Migration
  def up
    change_column :conferences, :schedule_xml, :text, limit: 4294967295
  end

  def down
    change_column :conferences, :schedule_xml, :binary
  end
end
