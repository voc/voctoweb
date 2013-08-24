class AddThumbFilenameToEvent < ActiveRecord::Migration
  def change
    add_column :events, :thumb_filename, :string
  end
end
