class AddFolderToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :folder, :string
  end
end
