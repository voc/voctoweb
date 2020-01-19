class ExtendConferenceAttributes < ActiveRecord::Migration[5.1]
  def change
    add_column :conferences, :description, :text
    add_column :conferences, :link, :string
  end
end
