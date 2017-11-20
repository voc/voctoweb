class AddEventInfoFieldsToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :date, :date
    add_column :events, :description, :text
    add_column :events, :link, :string
    add_column :events, :persons, :text
    add_column :events, :slug, :string
    add_column :events, :subtitle, :string
    add_column :events, :tags, :text
  end
end
