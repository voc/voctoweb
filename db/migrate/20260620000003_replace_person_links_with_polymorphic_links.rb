class ReplacePersonLinksWithPolymorphicLinks < ActiveRecord::Migration[7.2]
  def change
    drop_table :person_links

    create_table :links do |t|
      t.references :linkable, polymorphic: true, null: false
      t.string :url,       null: false
      t.string :name
      t.string :link_type
      t.string :service

      t.timestamps
    end

    add_index :links, [:linkable_type, :linkable_id, :url], unique: true
  end
end
