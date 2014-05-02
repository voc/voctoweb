ActiveAdmin.register Event do

  index do
    selectable_column
    column :guid
    column :title
    column :thumb_filename do |event|
      line_break_filename event.thumb_filename
    end
    column :gif_filename do |event| 
      line_break_filename event.gif_filename
    end
    column :poster_filename do |event|
      line_break_filename event.poster_filename
    end
    column :conference
    column :promoted
    column :created_at do |event|
      l(event.created_at, format: :pretty_datetime)
    end
    default_actions
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :guid
      f.input :title
      f.input :thumb_filename
      f.input :gif_filename
      f.input :poster_filename
      f.input :conference
      f.input :promoted
      f.input :subtitle 
      f.input :link
      f.input :slug
      f.input :description
      f.input :persons_raw, as: :text
      f.input :tags_raw, as: :text
      f.input :date
      f.input :release_date
    end
    f.actions
  end

  member_action :update_event_info, :method => :post do
    event = Event.find(params[:id])
    event.fill_event_info
    event.save
    redirect_to :action => :show
  end

  member_action :write_videopage_file, :method => :post do
    event = Event.find(params[:id])
    VideopageBuilder.save_videopage(event.conference, event)
    redirect_to :action => :show
  end

  action_item only: [:show, :edit] do
    if event.conference.downloaded?
      link_to 'Update event info from XML', update_event_info_admin_event_path(event), method: :post
    end
  end

  action_item only: :show do
    link_to 'Write Videopage file', write_videopage_file_admin_event_path(event), method: :post
  end

  batch_action :update_event_infos do |selection|
    Event.delay.bulk_update_events(selection)
    redirect_to :action => :index
  end

  batch_action :update_videopages do |selection|
    Event.delay.bulk_update_videopages(selection)
    redirect_to :action => :index
  end

  controller do
    def permitted_params
      params.permit event: [:guid, :thumb_filename, :gif_filename, :poster_filename, 
                            :conference_id, :promoted, :title, :subtitle, :link, :slug,
                            :description, :persons_raw, :tags_raw, :date, :event_id]
    end
  end

end
