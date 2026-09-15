class CreatePeopleTables < ActiveRecord::Migration[7.2]
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.string :public_name
      t.string :email
      t.string :avatar_url

      t.timestamps
    end

    add_index :people, :name, unique: true
    add_index :people, :public_name

    create_table :participations do |t|
      t.references :event,  null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.integer :role, default: 0, null: false
      t.integer :order
      t.string  :url

      t.timestamps
    end

    add_index :participations, [:event_id, :person_id], unique: true
    add_index :participations, [:event_id, :order]

    create_table :person_identifiers do |t|
      t.references :person, null: false, foreign_key: true
      t.string  :guid, null: false
      t.string  :source
      t.string  :origin
      t.integer :order

      t.timestamps
    end

    add_index :person_identifiers, :guid
    add_index :person_identifiers, [:guid, :source], unique: true
  end
end
