class DefaultLanguageIsEng < ActiveRecord::Migration[4.2]
  def change
    change_column :recordings, :language, :string, default: 'eng'
  end
end
