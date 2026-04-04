class EventTagsAsArray < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :structured_tags, :string, array: true, default: [], null: false
    add_index :events, :structured_tags, using: :gin
    Event.all.each { |event|
      # we use update_columns instead of update_attribute to skip elasticsearch reindexing
      event.update_columns(structured_tags: event.tags)
    }
  end

  def down
    remove_column :events, :structured_tags
  end
end
