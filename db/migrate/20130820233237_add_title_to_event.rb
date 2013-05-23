class AddTitleToEvent < ActiveRecord::Migration
  def change
    add_column :events, :title, :string
  end
end
