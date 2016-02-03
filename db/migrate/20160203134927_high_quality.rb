class HighQuality < ActiveRecord::Migration
  def change
    rename_column :recordings, :hd_quality, :high_quality
  end
end
