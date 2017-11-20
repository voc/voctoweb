class CreateRecordings < ActiveRecord::Migration[4.2]
  def change
    create_table :recordings do |t|
      t.integer :size
      t.integer :length
      t.string :mime_type
      t.references :event, index: true

      t.timestamps
    end
  end
end
