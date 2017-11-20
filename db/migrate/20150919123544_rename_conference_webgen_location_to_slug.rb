class RenameConferenceWebgenLocationToSlug < ActiveRecord::Migration[4.2]
  def change
    rename_column :conferences, :webgen_location, :slug
    change_column :conferences, :slug, :string, default: ''
  end
end
