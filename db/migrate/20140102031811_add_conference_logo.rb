class AddConferenceLogo < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :logo, :string
  end
end
