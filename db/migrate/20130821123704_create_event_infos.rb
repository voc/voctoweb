class CreateEventInfos < ActiveRecord::Migration[4.2]
  def change
    create_table :event_infos do |t|
      t.references :event, index: true
      t.string :subtitle
      t.string :link
      t.text :description
      t.text :persons
      t.text :tags
      t.date :date

      t.timestamps
    end
  end
end
