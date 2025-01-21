class AddTranslatedToRecordings < ActiveRecord::Migration[7.2]
  def up
    add_column :recordings, :translated, :boolean, default: false, null: false

    execute "UPDATE recordings SET translated = true WHERE folder LIKE '%transla%'"
  end

  def down
    remove_column :recordings, :translated
  end
end
