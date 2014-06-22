class RemoveReleasedStateFromRecording < ActiveRecord::Migration
  def up
    execute %{
    UPDATE recordings SET state='downloaded' WHERE state='released'
    }
  end
end
