class AddQualityFlagOnRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :hd_quality, :boolean, default: true, null: false
  end
end
