class ChangeReleaseDateToDate < ActiveRecord::Migration[4.2]
  def up
    change_column :import_templates, :release_date, :date
    change_column :events, :release_date, :date
  end

  def down
    change_column :import_templates, :release_date, :datetime
    change_column :events, :release_date, :datetime
  end
end
