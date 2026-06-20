class CreatePersonIdentifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :person_identifiers do |t|
      t.references :person, null: false, foreign_key: true
      t.string :guid, null: false
      t.string :source

      t.timestamps
    end

    add_index :person_identifiers, :guid
    add_index :person_identifiers, [:guid, :source], unique: true
  end
end
