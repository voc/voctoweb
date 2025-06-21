class AddVideoCodecToRecordings < ActiveRecord::Migration[7.2]
  def change
    add_column :recordings, :video_codec, :string
    add_index :recordings, :video_codec
  end
end

