class AddDimensionsToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :width, :integer
    add_column :recordings, :height, :integer
  end
end
