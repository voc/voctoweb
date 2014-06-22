ActiveAdmin.register Recording do

  index do
    selectable_column
    column :original_url
    column :filename do |recording|
      line_break_filename recording.filename
    end
    column :folder
    column :mime_type
    column :size
    column :length
    column :state
    column :updated_at do |recording|
      l(recording.updated_at, format: :pretty_datetime)
    end
    actions
  end

  show do |r|
    attributes_table do
      row :filename do
        div show_recording_path r
        div show_recording_url r
      end
      row :folder
      row :event
      row :original_url
      row :state
      row :mime_type
      row :size
      row :length
      row :width
      row :height
    end
  end

  form do |f|
    f.inputs "Recording Details" do
      f.input :event
      f.input :folder, hint: recording.try(:conference).try(:get_recordings_path)
      f.input :filename, hint: recording.try(:get_recording_dir)
      f.input :mime_type, collection: Recording::HTML5
      f.input :size
      f.input :length
      f.input :width
      f.input :height
      f.input :original_url
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit recording: [:original_url, :folder, :filename, :mime_type, :size, :length, :width, :height, :event_id]
    end
  end

end
