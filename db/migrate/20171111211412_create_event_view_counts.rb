class CreateEventViewCounts < ActiveRecord::Migration[5.1]
  def change
    create_table :event_view_counts do |t|
      t.timestamp :last_updated_at
    end

    connection.execute("INSERT INTO event_view_counts (last_updated_at) VALUES (NOW())")
  end
end
