class AddConferenceIndexes < ActiveRecord::Migration[4.2]
  def up
    add_index :conferences, :acronym
  end

  def down
    remove_index :conferences, :column => :acronym
  end
end
