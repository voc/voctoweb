class ChangeRecordingModel < ActiveRecord::Migration
  def change
    rename_column :recordings, :path, :filename
    add_column :recordings, :original_url, :string
  end
end
