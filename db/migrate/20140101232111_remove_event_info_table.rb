class RemoveEventInfoTable < ActiveRecord::Migration
  def change
    drop_table :event_infos
  end
end
