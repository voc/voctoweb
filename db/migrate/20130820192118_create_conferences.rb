class CreateConferences < ActiveRecord::Migration
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
