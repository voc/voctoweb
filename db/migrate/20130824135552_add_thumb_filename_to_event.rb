class AddThumbFilenameToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :thumb_filename, :string
  end
end
