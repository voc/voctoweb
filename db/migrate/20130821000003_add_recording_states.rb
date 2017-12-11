class AddRecordingStates < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :state, :string, default: "new", null: false
    add_index :events, :state
  end
end
