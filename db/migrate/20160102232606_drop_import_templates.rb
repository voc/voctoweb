class DropImportTemplates < ActiveRecord::Migration
  def change
    drop_table :import_templates
  end
end
