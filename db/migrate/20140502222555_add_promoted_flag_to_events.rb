class AddPromotedFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :promoted, :boolean
  end
end
