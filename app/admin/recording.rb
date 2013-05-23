ActiveAdmin.register Recording do

  index do
    column :path
    column :mime_type
    column :size
    column :length
    column :created_at
    default_actions
  end

  form do |f|
    f.inputs "Recording Details" do
      f.input :path
      f.input :mime_type
      f.input :size
      f.input :length
      f.input :event
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit api_key: [:path, :mime_type, :size, :length, :event]
    end
  end

end
