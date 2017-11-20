class RemovePromotedFromImportTemplate < ActiveRecord::Migration[4.2]
  def up
    remove_column :import_templates, :promoted
  end

  def down
    add_column :import_templates, :promoted, :boolean
  end
end
