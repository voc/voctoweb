class AddFolderToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :folder, :string
  end
end
