class AddStreamingToConference < ActiveRecord::Migration[5.1]
  def change
    add_column :conferences, :streaming, :jsonb, index: true, default: {}
    add_index  :conferences, :streaming, using: :gin
  end
end
