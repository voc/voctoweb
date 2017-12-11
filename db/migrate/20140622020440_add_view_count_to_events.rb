class AddViewCountToEvents < ActiveRecord::Migration[4.2]

  def up
    add_column :events, :view_count, :integer, default: 0

    execute %{
      UPDATE events SET view_count=0;
    }
  end

  def down
    remove_column :events, :view_count
  end

end
