class CreateApiKeys < ActiveRecord::Migration[4.2]
  def change
    create_table :api_keys do |t|
      t.string :key
      t.string :description

      t.timestamps
    end
  end
end
