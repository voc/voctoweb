ActiveAdmin.register Recording do

  index do
    column :original_url
    column :filename
    column :mime_type
    column :size
    column :length
    column :state
    column :updated_at
    default_actions
  end

  form do |f|
    f.inputs "Recording Details" do
      f.input :original_url
      f.input :filename
      f.input :mime_type
      f.input :size
      f.input :length
      f.input :event
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit recording: [:original_url, :filename, :mime_type, :size, :length, :event_id]
    end
  end

end
