class AddIndexesToEvents < ActiveRecord::Migration[4.2]
  def change
    add_index :events, :guid
    add_index :events, :title
  end
end
