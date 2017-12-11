class AddTimeToEventDate < ActiveRecord::Migration[4.2]
  def change
    change_column :events, :date, :datetime
  end
end
