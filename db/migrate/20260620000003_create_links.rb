class CreateLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :links do |t|
      t.references :linkable, polymorphic: true, null: false
      t.string  :url,   null: false
      t.string  :name
      t.string  :link_type
      t.string  :service
      t.integer :order

      t.timestamps
    end

    add_index :links, [:linkable_type, :linkable_id, :url], unique: true
  end
end
