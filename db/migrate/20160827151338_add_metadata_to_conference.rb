class AddMetadataToConference < ActiveRecord::Migration
  def change
    add_column :conferences, :metadata, :jsonb, index: true, default: {}
  end
end
