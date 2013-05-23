class AddPathToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :path, :string
  end
end
