class CreateImportTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :import_templates do |t|

      #conference

      t.string   "acronym"
      t.string   "title"
      t.string   "logo"
      t.string   "webgen_location"
      t.string   "aspect_ratio"
      t.string   "recordings_path"
      t.string   "images_path"

      #events

      t.date     "date"
      t.datetime "release_date"
      t.boolean  "promoted"

      #recordings

      t.string   "mime_type"
      t.string   "folder"
      t.integer  "width"
      t.integer  "height"

      t.timestamps
    end
  end
end
