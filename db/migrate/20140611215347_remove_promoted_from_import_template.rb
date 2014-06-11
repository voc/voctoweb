class RemovePromotedFromImportTemplate < ActiveRecord::Migration
  def up
    remove_column :import_templates, :promoted
  end

  def down
    add_column :import_templates, :promoted, :boolean
  end
end
