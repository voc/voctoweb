class AddPromotedFlagToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :promoted, :boolean
  end
end
