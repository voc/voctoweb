class AddTitleToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :title, :string
  end
end
