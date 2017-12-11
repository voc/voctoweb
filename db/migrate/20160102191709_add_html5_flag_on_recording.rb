class AddHtml5FlagOnRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :html5, :boolean, default: false, null: false
  end
end
