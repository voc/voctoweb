class AddLanguageStringToRecording < ActiveRecord::Migration[4.2]
  def change
    add_column :recordings, :language, :string, default: 'en'
  end
end
