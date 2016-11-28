class AddEventLastReleasesAtToConference < ActiveRecord::Migration[5.0]
  def change
    add_column :conferences, :event_last_released_at, :date, null: true

    reversible do |dir|
      dir.up do
        # initialize field content
        execute <<-SQL
          UPDATE conferences
          SET event_last_released_at = (
            SELECT MAX(release_date)
            FROM events
            WHERE events.conference_id = conferences.id
          );
        SQL
      end
    end
  end

end
