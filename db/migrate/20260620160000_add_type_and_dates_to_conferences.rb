class AddTypeAndDatesToConferences < ActiveRecord::Migration[7.2]
  def change
    add_column :conferences, :conference_type, :string
    add_column :conferences, :starts_at, :datetime
    add_column :conferences, :ends_at, :datetime
    add_column :conferences, :languages, :string, array: true, default: []
  end
end
