class RenameImportTemplateWebgenLocationToSlug < ActiveRecord::Migration[4.2]
  def change
    rename_column :import_templates, :webgen_location, :slug
  end
end
