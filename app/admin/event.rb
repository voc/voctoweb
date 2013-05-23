ActiveAdmin.register Event do

  index do
    column :guid
    column :gif_filename
    column :poster_filename
    column :conference
    column :created_at
    default_actions
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :guid
      f.input :gif_filename
      f.input :poster_filename
      f.input :conference
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit event: [:guid, :gif_filename, :poster_filename, :conference_id]
    end
  end

end
