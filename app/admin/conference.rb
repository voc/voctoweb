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
    actions
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
      row :webgen_location
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
    table_for c.events.order('slug ASC') do
      column "Events" do |event|
        link_to "#{event.slug} (#{event.title})", [ :admin, event ]
      end
    end
  end

  form do |f|
    f.inputs "Conference Details" do
      f.input :acronym
      f.input :title
      f.input :schedule_url
      f.input :aspect_ratio, collection: Conference::ASPECT_RATIO
      f.input :webgen_location
    end
    f.inputs "Paths" do
      f.input :recordings_path, hint: conference.get_recordings_path
      f.input :images_path, hint: conference.get_images_path
    end
    f.inputs "Files" do
      f.input :logo, hint: conference.get_logo_dir
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

  action_item only: [:show, :edit] do
    link_to 'Add Event', new_admin_event_path(event: {conference_id: conference.id}), method: :get
  end

  action_item do
    link_to 'Compile', run_compile_admin_conferences_path, method: :post
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
