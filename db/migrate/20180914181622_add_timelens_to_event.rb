class AddTimelensToEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :timeline_filename, :string, :default => ''
    add_column :events, :thumbnails_filename, :string, :default => ''
  end
end
