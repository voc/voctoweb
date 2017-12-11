class RemoveOriginalUrl < ActiveRecord::Migration[4.2]
  def change
    remove_column :recordings, :original_url
  end
end
