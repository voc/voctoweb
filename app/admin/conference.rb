ActiveAdmin.register Conference do

  index do
    column :acronym
    column :schedule_url
    column :schedule_state
    column :recordings_path
    column :webgen_location
    column :created_at
    default_actions
  end

  form do |f|
    f.inputs "Conference Details" do
      f.input :acronym
      f.input :recordings_path
      f.input :images_path
      f.input :webgen_location
      f.input :schedule_url
      f.input :aspect_ratio
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit conference: [ :acronym,
                                  :schedule_url,
                                  :recordings_path,
                                  :images_path,
                                  :webgen_location,
                                  :aspect_ratio ]
    end
  end



end
