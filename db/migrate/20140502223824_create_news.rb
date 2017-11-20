class CreateNews < ActiveRecord::Migration[4.2]
  def change
    create_table :news do |t|
      t.string :title
      t.text :body
      t.date :date

      t.timestamps
    end
  end
end
