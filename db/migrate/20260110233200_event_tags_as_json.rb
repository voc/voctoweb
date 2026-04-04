class EventTagsAsJson < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :structured_tags, :string, array: true, default: [], null: false
    Event.all.each { |event|
      event.update_attribute(:structured_tags, event.tags)
    }
  end

  def down
    remove_column :events, :structured_tags
  end
end
