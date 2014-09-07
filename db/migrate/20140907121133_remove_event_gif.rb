class RemoveEventGif < ActiveRecord::Migration
  def change
    remove_column :events, :gif_filename
  end
end
