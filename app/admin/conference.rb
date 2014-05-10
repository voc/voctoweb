ActiveAdmin.register Conference do

  index do
    selectable_column
    column :acronym
    column :schedule_url
    column :schedule_state
    column :recordings_path
    column :webgen_location
    column :created_at do |conference|
      l(conference.created_at, format: :pretty_datetime)
    end
    default_actions
  end

  show do |c|
    attributes_table do
      row :acronym
      row :title
      row :recordings_path do
        div show_folder label: c.recordings_path, path: c.get_recordings_path
      end
      row :images_path do
        div show_folder label: c.images_path, path: c.get_images_path
      end
      row :webgen_location do
        div show_folder label: c.webgen_location, path: c.get_webgen_location
      end
      row :logo do
        div show_logo_path c
        div show_logo_url c
      end
      row :aspect_ratio
      row :schedule_url
      row :schedule_xml do
        div c.schedule_xml.try(:truncate,200)
      end
      row :schedule_state
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Conference Details" do
      f.input :acronym
      f.input :title
      f.input :recordings_path
      f.input :images_path
      f.input :webgen_location
      f.input :schedule_url
      f.input :aspect_ratio
    end
    f.actions
  end

  member_action :download_schedule, method: :post do
    conference = Conference.find(params[:id])
    unless conference.schedule_url.empty?
      conference.url_changed
    end
    redirect_to action: :show
  end

  collection_action :run_compile, method: :post do
    Conference.delay.run_compile_job
    redirect_to action: :index
  end

  action_item only: :show do
    link_to 'Download Schedule', download_schedule_admin_conference_path(conference), method: :post
  end

  action_item do
    link_to 'Releasing', run_compile_admin_conferences_path, method: :post
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
