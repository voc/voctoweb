ActiveAdmin.register EventInfo do

  index do
    column :subtitle
    column :link
    column :tags
    column :date
    column :updated_at
    default_actions
  end

  form do |f|
    f.inputs "Recording Details" do
      f.input :subtitle
      f.input :link
      f.input :description
      f.input :persons
      f.input :tags
      f.input :date
      f.input :event
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit event_info: [:subtitle, :link, :description, :persons, :tags, :date, :event_id]
    end
  end

end
