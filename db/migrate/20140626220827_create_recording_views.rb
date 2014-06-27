class CreateRecordingViews < ActiveRecord::Migration
  def change
    create_table :recording_views do |t|
      t.references :recording, index: true
      t.timestamps
    end
  end
end
