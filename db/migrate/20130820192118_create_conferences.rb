class CreateConferences < ActiveRecord::Migration[4.2]
  def change
    create_table :conferences do |t|
      t.string :acronym
      t.string :recordings_path
      t.string :images_path
      t.string :webgen_location
      t.string :aspect_ratio

      t.timestamps
    end
  end
end
