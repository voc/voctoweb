class DropImportTemplates < ActiveRecord::Migration[4.2]
  def change
    drop_table :import_templates
  end
end
