class AddNotesFieldToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :notes, :string
  end
end
