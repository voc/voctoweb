class CreateRecordingViews < ActiveRecord::Migration[4.2]
  def change
    create_table :recording_views do |t|
      t.references :recording, index: true
      t.timestamps
    end
  end
end
