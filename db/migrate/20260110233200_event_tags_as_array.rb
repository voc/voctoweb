class EventTagsAsArray < ActiveRecord::Migration[7.2]
  def up
    add_column :events, :structured_tags, :string, array: true, default: [], null: false
    add_index :events, :structured_tags, using: :gin

    # we can not safely use the Event model here, so lets do it with raw SQL and YAML parsing
    rows = execute("SELECT id, tags FROM events WHERE tags IS NOT NULL")
    rows.each do |event|
      tags = YAML.load(event["tags"].to_s)
      execute <<~SQL
        UPDATE events
        SET structured_tags = ARRAY[#{tags.map { |t| connection.quote(t) }.join(', ')}]::text[]
        WHERE id = #{event['id'].to_i}
      SQL
    end
  end

  def down
    remove_column :events, :structured_tags
  end
end
