class AddGlobalEventNotesFieldToConference < ActiveRecord::Migration[7.2]
  def change;
    add_column :conferences, :global_event_notes, :string
  end
end
