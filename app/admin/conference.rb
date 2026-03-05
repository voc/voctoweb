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
      row :global_event_notes
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
      f.input :global_event_notes, hint: 'Notes to be shown as a notice on the page of every lecture in this conference'
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

  member_action :duplicate, method: :post do
    original = Conference.find(params[:id])
    copy = original.dup

    current_year = Time.current.year.to_s
    previous_year = (Time.current.year - 1).to_s

    if original.acronym&.include?(previous_year) or original.recordings_path&.include?(previous_year)

      %i[slug title link recordings_path images_path schedule_url acronym].each do |field|
        value = original.public_send(field)
        next if value.blank?

        copy.public_send("#{field}=", value.gsub(previous_year, current_year))
      end

      if not original.acronym&.include?(previous_year) and original.acronym&.match?(/\d+/)
        num = original.acronym[/\d+/].to_i
        copy.acronym = original.acronym.gsub(num.to_s, (num + 1).to_s)

        if not original.title&.include?(previous_year) and original.title&.include?(num.to_s)
          copy.title = original.title.gsub(num.to_s, (num + 1).to_s)
        end
      end

    else
      copy.acronym = "duplicate-of-#{original.slug}"
      copy.title = "Duplicate of #{original.title}"
      copy.slug = "#{original.slug}+1"
    end
    if copy.save
      redirect_to edit_admin_conference_path(copy), notice: 'Conference duplicated successfully.'
    else
      redirect_to admin_conference_path(original), alert: "Failed to duplicate conference as #{copy.acronym}."
    end
  end

  action_item(:add_event, only: [:show, :edit]) do
    link_to 'View', conference_path(acronym: conference.acronym), method: :get
  end

  action_item(:download_schedule, only: :show) do
    link_to 'Download Schedule', download_schedule_admin_conference_path(conference), method: :post
  end

  action_item(:duplicate, only: [:show, :edit]) do
    link_to 'Duplicate', duplicate_admin_conference_path(conference), method: :post, data: { confirm: 'Are you sure you want to duplicate this conference?' }
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
                                  :global_event_notes,
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
