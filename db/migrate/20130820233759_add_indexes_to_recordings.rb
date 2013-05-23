class AddIndexesToRecordings < ActiveRecord::Migration
  def change
    add_index :recordings, :path
    add_index :recordings, :mime_type
  end
end
