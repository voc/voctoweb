class AddConferenceIndexes < ActiveRecord::Migration
  def up
    add_index :conferences, :acronym
  end

  def down
    remove_index :conferences, :column => :acronym
  end
end
