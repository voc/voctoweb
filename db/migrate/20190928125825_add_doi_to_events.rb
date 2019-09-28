class AddDoiToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :doi, :string
  end
end
