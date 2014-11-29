ActiveAdmin.register Event do

  filter :guid
  filter :title
  filter :link
  filter :conference
  filter :promoted
  filter :slug
  filter :tags
  filter :date
  filter :release_date
  filter :updated_at

  index do
    selectable_column
    column :guid
    column :title
    column :thumb_filename do |event|
      line_break_filename event.thumb_filename
    end
    column :poster_filename do |event|
      line_break_filename event.poster_filename
    end
    column :conference
    column :promoted
    column :created_at do |event|
      l(event.created_at, format: :pretty_datetime)
    end
    actions
  end

  show do |e|
    attributes_table do
      row :guid
      row :title
      row :thumb_filename do
        div show_event_folder e, :thumb_filename
      end
      row :poster_filename do
        div show_event_folder e, :poster_filename
      end
      row :conference
      row :promoted
      row :subtitle
      row :link
      row :slug
      row :description
      row :persons
      row :tags
      row :date
      row :release_date
    end
    table_for e.recordings.order('filename ASC') do
      column "Recordings" do |recording|
        link_to recording.filename, [ :admin, recording ]
      end
    end
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :guid
      f.input :conference
      f.input :title
      f.input :subtitle
      f.input :description
      f.input :link
      f.input :promoted
      f.input :persons_raw, as: :text
      f.input :tags_raw, as: :text
      f.input :date, hint: 'Actual date of the event'
      f.input :release_date, hint: 'Release date for the video recordings'
    end
    f.inputs "Files" do
      f.input :slug
      f.input :thumb_filename, hint: event.try(:conference).try(:get_images_path)
      f.input :poster_filename, hint: event.try(:conference).try(:get_images_path)
    end
    f.actions
  end

  member_action :update_event_info, :method => :post do
    event = Event.find(params[:id])
    event.fill_event_info
    event.save
    redirect_to :action => :show
  end

  collection_action :update_promoted_from_view_count, method: :post do
    Event.update_promoted_from_view_count
    redirect_to :action => :index
  end

  action_item(:update_event_info, only: [:show, :edit]) do
    if event.conference.downloaded?
      link_to 'Update event info from XML', update_event_info_admin_event_path(event), method: :post
    end
  end

  action_item(:add_recording, only: [:show, :edit]) do
    link_to 'Add Recording', new_admin_recording_path(recording: {event_id: event.id}), method: :get
  end

  action_item(:update_promoted) do
    link_to 'Update promoted', update_promoted_from_view_count_admin_events_path, method: :post
  end

  batch_action :update_event_infos do |selection|
    Event.delay.bulk_update_events(selection)
    redirect_to :action => :index
  end

  controller do
    def permitted_params
      params.permit event: [:guid, :thumb_filename, :poster_filename,
                            :conference_id, :promoted, :title, :subtitle, :link, :slug,
                            :description, :persons_raw, :tags_raw, :date, :release_date, :event_id]
    end
  end

end
