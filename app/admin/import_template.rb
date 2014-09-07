ActiveAdmin.register ImportTemplate do

  index do
    selectable_column

    column :state

    # conference
    column :acronym
    column :title
    column :logo
    column :webgen_location
    column :aspect_ratio
    column :recordings_path
    column :images_path

    # events
    column :date do |it|
      l(it.date, format: :pretty)
    end
    column :release_date do |it|
      l(it.release_date, format: :pretty)
    end

    # recordings
    column :mime_type
    column :folder
    column :width
    column :height

    actions
  end

  show do |c|
    attributes_table do
      row :acronym
      row :title
      row :webgen_location
      row :aspect_ratio
      row :recordings_path do
        div show_folder label: c.recordings_path, path: c.get_recordings_path
      end
      row :images_path do
        div show_folder label: c.images_path, path: c.get_images_path
      end
      row :logo do
        div show_logo_path c
        div show_logo_url c
      end

      # events
      row :date do |it|
        l(it.date, format: :pretty)
      end
      row :release_date do |it|
        l(it.release_date, format: :pretty)
      end

      # recordings
      row :folder
      row :mime_type
      row :width
      row :height
    end

    table_for c.recordings do
      column :filename
      column :poster do |r|
        r.poster.found
      end
      column :thumb do |r|
        r.thumb.found
      end
    end

    # TODO list left-over media files?
  end

  form do |f|
    f.inputs "Conference Details" do
      f.input :acronym
      f.input :title
      f.input :aspect_ratio, collection: Conference::ASPECT_RATIO
      f.input :webgen_location
    end

    f.inputs "Paths" do
      f.input :recordings_path, hint: import_template.get_recordings_path
      f.input :images_path, hint: import_template.get_images_path
    end

    f.inputs "Files" do
      f.input :logo, hint: import_template.get_logo_dir
    end

    f.inputs "Events" do
      f.input :date, hint: 'Actual date of the event'
      f.input :release_date, hint: 'Release date for the video recordings'
    end

    f.inputs "Recordings" do
      f.input :folder, hint: import_template.get_recordings_path
      f.input :mime_type, collection: Recording::HTML5
      f.input :width
      f.input :height
    end

    f.actions
  end

  member_action :import_conference, method: :post do
    import_template = ImportTemplate.find(params[:id])
    ActiveRecord::Base.transaction do
      ConferenceImporter.import(import_template)
    end
    redirect_to action: :index
  end

  action_item only: :show do
    link_to 'Import Conference', import_conference_admin_import_template_path(import_template), method: :post
  end

  permit_params :acronym, :title, :aspect_ratio, :webgen_location, :recordings_path, :images_path, :logo, :date, :release_date, :folder, :mime_type, :width, :height


end
