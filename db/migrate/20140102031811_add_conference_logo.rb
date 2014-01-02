class AddConferenceLogo < ActiveRecord::Migration
  def change
    add_column :conferences, :logo, :string
  end
end
