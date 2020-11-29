class AddIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index 'events', ['slug'], name: 'index_events_on_slug'
    add_index 'events', ['release_date'], name: 'index_events_on_release_date'
    add_index 'events', %w(slug id), name: 'index_events_on_slug_and_id'
    #add_index 'recordings', %w(state mime_type), name: 'index_recordings_on_state_and_mime_type'
  end
end
