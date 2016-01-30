class RemoveOriginalUrl < ActiveRecord::Migration
  def change
    remove_column :recordings, :original_url
  end
end
