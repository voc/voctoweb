class AddLanguageStringToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :language, :string, default: 'en'
  end
end
