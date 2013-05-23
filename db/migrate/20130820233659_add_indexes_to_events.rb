class AddIndexesToEvents < ActiveRecord::Migration
  def change
    add_index :events, :guid
    add_index :events, :title
  end
end
