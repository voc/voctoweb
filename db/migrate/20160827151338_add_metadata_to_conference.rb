class AddMetadataToConference < ActiveRecord::Migration[4.2]
  def change
    add_column :conferences, :metadata, :jsonb, index: true, default: {}
  end
end
