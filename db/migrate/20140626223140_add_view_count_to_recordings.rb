class AddViewCountToRecordings < ActiveRecord::Migration[4.2]
  def up
    add_column :recordings, :view_count, :integer, default: 0

    execute %{
      UPDATE recordings SET view_count=0;
    }
  end

  def down
    remove_column :recordings, :view_count
  end

end
