class RenameEventsTagsToTagsYaml < ActiveRecord::Migration[7.2]
  def change
    rename_column :events, :tags, :tags_yaml
    rename_column :events, :structured_tags, :tags
  end
end
