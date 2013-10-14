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

  show do |c|
    attributes_table do
      row :acronym
      row :recordings_path
      row :images_path
      row :webgen_location
      row :aspect_ratio
      row :created_at
      row :updated_at
      row :title
      row :schedule_url
      row :schedule_xml do
        div c.schedule_xml.truncate(200)
      end
      row :schedule_state
    end
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

  member_action :create_vgallery, :method => :post do
    conference = Conference.find(params[:id])
    conference.create_videogallery!
    redirect_to :action => :show
  end

  member_action :download_schedule, :method => :post do
    conference = Conference.find(params[:id])
    unless conference.schedule_url.empty?
      conference.download!
    end
    redirect_to :action => :show
  end

  member_action :create_podcast, :method => :post do
    conference = Conference.find(params[:id])
    conference.create_podcast
    redirect_to :action => :show
  end

  collection_action :run_webgen, :method => :post do
    Conference.delay.run_webgen_job
    redirect_to :action => :index
  end

  action_item only: :show do
    link_to 'Create Gallery Index', create_vgallery_admin_conference_path(conference), method: :post
  end

  action_item only: :show do
    link_to 'Download Schedule', download_schedule_admin_conference_path(conference), method: :post
  end

  action_item only: :show do
    link_to 'Create Podcast', create_podcast_admin_conference_path(conference), method: :post
  end

  action_item do
    link_to 'Run Webgen', run_webgen_admin_conferences_path, method: :post
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
