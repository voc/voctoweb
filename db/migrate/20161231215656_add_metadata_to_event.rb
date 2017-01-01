class AddMetadataToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :metadata, :jsonb, index: true, default: {}
    add_index  :events, :metadata, using: :gin
  end
end
