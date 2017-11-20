class HighQuality < ActiveRecord::Migration[4.2]
  def change
    rename_column :recordings, :hd_quality, :high_quality
  end
end
