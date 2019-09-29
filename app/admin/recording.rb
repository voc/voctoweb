ActiveAdmin.register Recording do
  menu :parent => "Misc"

  filter :state
  filter :mime_type, collection: proc { MimeType.all }
  filter :language
  filter :filename
  filter :folder
  filter :html5
  filter :high_quality
  filter :conference, :collection => proc { Conference.all }
  filter :event, :collection => proc { Event.includes(:conference).all }
  filter :updated_at

  index do
    selectable_column
    column :filename do |recording|
      line_break_filename recording.filename
    end
    #column :folder
    column :mime_type
    column :html5
    column :high_quality
    column :language
    #column :size
    #column :length
    #column :state
    column :updated_at do |recording|
      l(recording.updated_at, format: :pretty_datetime)
    end
    actions
  end

  show do |r|
    attributes_table do
      row :filename do
        div show_recording_url r
      end
      row :folder
      row :event
      row :mime_type
      row :html5
      row :high_quality
      row :language
      row :size
      row :length
      row :width
      row :height
      row :state
    end
  end

  form do |f|
    f.inputs "Recording Details" do
      f.input :event
      f.input :mime_type, collection: MimeType.all
      f.input :html5
      f.input :language, hint: 'ISO-639-2 codes (deu, eng), delimeted by -'
      f.input :size, label: 'file size in mb'
      f.input :length, label: 'run-time in seconds'
      f.input :high_quality
      f.input :width
      f.input :height
    end
    f.inputs "Storage" do
      f.input :folder, hint: recording.try(:conference).try(:get_recordings_url)
      f.input :filename
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit recording: [:folder, :filename, :mime_type, :language, :html5, :high_quality, :size, :length, :width, :height, :state, :event_id]
    end
  end
end
