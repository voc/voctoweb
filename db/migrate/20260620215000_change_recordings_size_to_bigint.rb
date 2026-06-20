class ChangeRecordingsSizeToBigint < ActiveRecord::Migration[7.2]
  def change
    change_column :recordings, :size, :bigint, comment: "file size in bytes"
  end
end
