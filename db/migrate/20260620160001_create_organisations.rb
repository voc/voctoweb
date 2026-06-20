class CreateOrganisations < ActiveRecord::Migration[7.2]
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.string :url
      t.text :description
      t.date :inception_date
      t.string :wikidata_id

      t.timestamps
    end

    add_index :organisations, :name, unique: true
    add_index :organisations, :wikidata_id, unique: true, where: 'wikidata_id IS NOT NULL'

    create_table :conferences_organizers, id: false do |t|
      t.belongs_to :conference, null: false, index: true
      t.belongs_to :organisation, null: false, index: true
    end
  end
end
