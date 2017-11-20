class AddIndexesToRecordings < ActiveRecord::Migration[4.2]
  def change
    add_index :recordings, :path
    add_index :recordings, :mime_type
  end
end
