class RemoveEventInfoTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :event_infos
  end
end
