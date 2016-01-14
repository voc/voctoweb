class AddHtml5FlagOnRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :html5, :boolean, default: false, null: false
  end
end
