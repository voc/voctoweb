class RemoveViewCountFromRecordings < ActiveRecord::Migration[4.2]
  def up
    remove_column :recordings, :view_count
  end
  def down
    add_column :recordings, :view_count, :integer, default: 0
    execute %{ UPDATE recordings SET view_count=0; }
  end
end
