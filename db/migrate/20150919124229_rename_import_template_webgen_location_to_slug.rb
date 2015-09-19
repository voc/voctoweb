class RenameImportTemplateWebgenLocationToSlug < ActiveRecord::Migration
  def change
    rename_column :import_templates, :webgen_location, :slug
  end
end
