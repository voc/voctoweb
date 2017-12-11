class AddSlugToEventInfo < ActiveRecord::Migration[4.2]
  def change
    add_column :event_infos, :slug, :string
  end
end
