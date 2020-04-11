class AddCustomCssToConference < ActiveRecord::Migration[5.1]
  def change
    add_column :conferences, :custom_css, :text
  end
end
