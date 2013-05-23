class AddTitleToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :title, :string
  end
end
