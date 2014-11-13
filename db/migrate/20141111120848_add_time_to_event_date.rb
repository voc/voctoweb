class AddTimeToEventDate < ActiveRecord::Migration
  def change
    change_column :events, :date, :datetime
  end
end
