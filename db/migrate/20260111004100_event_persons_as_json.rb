class EventPersonsAsJson < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :structured_persons, :string, array: true, default: [], null: false
    Event.all.each { |event|
      event.update_attribute(:structured_persons, event.persons)
    }
  end

  def down
    remove_column :events, :structured_persons
  end
end
