class AddSlugToEventInfo < ActiveRecord::Migration
  def change
    add_column :event_infos, :slug, :string
  end
end
