class AddDimensionsToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :width, :integer
    add_column :recordings, :height, :integer
  end
end
