class AddIdentifiersToRecordingViews < ActiveRecord::Migration[5.0]
  def change
    add_column :recording_views, :user_agent, :string, default: ''
    add_column :recording_views, :identifier, :string, default: ''
  end
end
