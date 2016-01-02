class AddQualityFlagOnRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :hd_quality, :boolean, default: true, null: false
  end
end
