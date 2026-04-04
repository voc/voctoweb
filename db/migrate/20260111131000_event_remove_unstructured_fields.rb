class EventRemoveUnstructuredFields < ActiveRecord::Migration[7.2]
  def up
    remove_column :events, :tags
    remove_column :events, :persons
  end

  def down
    add_column :events, :tags, :string, default: "", null: false
    add_column :events, :persons, :string, default: "", null: false
    Event.all.each { |event|
      event.update_attribute(:persons, event.structured_persons)
      event.update_attribute(:tags, event.structured_tags)
    }
  end
end
