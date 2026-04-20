class CreatePeople < ActiveRecord::Migration[7.2]
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.string :public_name
      t.string :email
      t.string :avatar_url
      t.text :description
      t.text :links, array: true, default: []
      
      t.timestamps
    end
    
    add_index :people, :name, unique: true
    add_index :people, :public_name
  end
end
