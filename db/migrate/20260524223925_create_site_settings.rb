class CreateSiteSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :site_settings do |t|
      t.string :promoted_banner_url
      t.string :live_banner_url
      t.string :logo_url
      t.string :logo_alt

      t.timestamps
    end
  end
end
