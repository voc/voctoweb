ActiveAdmin.register Recording do

  filter :state
  filter :mime_type
  filter :original_url
  filter :filename
  filter :folder
  filter :conference, :collection => proc { Conference.all }
  filter :event, :collection => proc { Event.includes(:conference).all }
  filter :updated_at

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
      row :mime_type
      row :size
      row :length
      row :state
    end
  end

  form do |f|
    f.inputs "Recording Details" do
      f.input :event
      f.input :mime_type, collection: MimeType::HTML5
      f.input :size
      f.input :length
      f.input :width
      f.input :height
      f.input :original_url
    end
    f.inputs "Storage" do
      f.input :folder, hint: recording.try(:conference).try(:get_recordings_path)
      f.input :filename, hint: recording.try(:get_recording_dir)
      f.input :state, collection: Recording.aasm.states.map(&:name)
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit recording: [:original_url, :folder, :filename, :mime_type, :size, :length, :width, :height, :state, :event_id]
    end
  end

end
