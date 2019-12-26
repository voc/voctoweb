class CreateWebFeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :web_feeds do |t|
      t.string :key
      t.string :kind
      t.timestamp :last_build
      t.text :content
    end
    add_index :web_feeds, %i{key kind}, unique: true
  end
end
