class ReplacePersonLinks < ActiveRecord::Migration[7.2]
  def change
    remove_column :people, :links, :text, array: true, default: []

    create_table :person_links do |t|
      t.references :person, null: false, foreign_key: true
      t.string :url, null: false
      t.string :title
      t.string :link_type
      t.string :service

      t.timestamps
    end
  end
end
