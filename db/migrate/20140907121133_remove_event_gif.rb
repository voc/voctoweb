class RemoveEventGif < ActiveRecord::Migration[4.2]
  def change
    remove_column :events, :gif_filename
  end
end
