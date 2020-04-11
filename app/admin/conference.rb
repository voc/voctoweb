ActiveAdmin.register Conference do

  filter :acronym
  filter :title
  filter :slug
  filter :recordings_path
  filter :images_path
  filter :updated_at

  index do
    selectable_column
    column :acronym
    column :slug
    column :recordings_path
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
        div show_folder label: c.recordings_path, path: c.get_recordings_url
      end
      row :images_path do
        div show_folder label: c.images_path, path: c.get_images_url
      end
      row :slug
      row :logo
      row :description
      row :link
      row :aspect_ratio
      row :schedule_url
      row :schedule_xml do
        div c.schedule_xml.try(:truncate, 200)
      end
      row :schedule_state
      row :created_at
      row :updated_at
      row :metadata do
        div c.metadata.try(:truncate, 200)
      end
      row :custom_css do
        div c.custom_css.try(:truncate, 200)
      end
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
      f.input :slug
      f.input :description #, input_html: { class: 'tinymce' }
      f.input :link
    end
    f.inputs "Paths" do
      f.input :recordings_path, hint: conference.get_recordings_url
      f.input :images_path, hint: conference.get_images_url
    end
    f.inputs "Files" do
      f.input :logo, hint: 'filename in images path'
      f.input :logo_does_not_contain_title, :as => :boolean, hint: 'displays title below conference logo in player view'
    end
    f.inputs "Meta" do
      f.input :subtitles, :as => :boolean, label: 'Conference has subtitles', hint: 'displays subtitle appeal below player'
      f.input :custom_css

    end
    f.actions
  end

  member_action :download_schedule, method: :post do
    conference = Conference.find(params[:id])
    unless conference.schedule_url.empty?
      conference.url_changed!
    end
    redirect_to action: :show
  end

  action_item(:add_event, only: [:show, :edit]) do
    link_to 'View', conference_path(acronym: conference.acronym), method: :get
  end
  
  action_item(:download_schedule, only: :show) do
    link_to 'Download Schedule', download_schedule_admin_conference_path(conference), method: :post
  end

  action_item(:add_event, only: [:show, :edit]) do
    link_to 'Add Event', new_admin_event_path(event: {conference_id: conference.id}), method: :get
  end

  controller do
    def permitted_params
      params.permit conference: [ :acronym,
                                  :title,
                                  :description,
                                  :link,
                                  :schedule_url,
                                  :recordings_path,
                                  :images_path,
                                  :logo,
                                  :logo_does_not_contain_title,
                                  :slug,
                                  :aspect_ratio,
                                  :subtitles,
                                  :custom_css,
                                ]
    end
  end



end
