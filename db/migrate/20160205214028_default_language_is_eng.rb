class DefaultLanguageIsEng < ActiveRecord::Migration
  def change
    change_column :recordings, :language, :string, default: 'eng'
  end
end
