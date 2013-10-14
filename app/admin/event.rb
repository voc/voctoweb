ActiveAdmin.register Event do

  index do
    column :guid
    column :thumb_filename
    column :gif_filename
    column :poster_filename
    column :conference
    column :created_at
    default_actions
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :guid
      f.input :thumb_filename
      f.input :gif_filename
      f.input :poster_filename
      f.input :conference

      unless [:downloading, :new].include? f.object.conference.schedule_state
        f.inputs "Info" do
          f.inputs :for => [:event_info, f.object.event_info || EventInfo.new] do |e|
            e.input :subtitle 
            e.input :link
            e.input :slug
            e.input :description
            e.input :persons_raw, as: :text
            e.input :tags_raw, as: :text
            e.input :date
          end
        end
      end

    end
    f.actions
  end

  member_action :update_event_info, :method => :post do
    event = Event.find(params[:id])
    event.event_info.destroy unless event.event_info.nil?
    event.fill_event_info
    event.event_info.save
    redirect_to :action => :show
  end

  action_item only: [:show, :edit] do
    link_to 'Update event info from XML', update_event_info_admin_event_path(event), method: :post
  end

  controller do
    def permitted_params
      params.permit event: [:guid, :thumb_filename, :gif_filename, :poster_filename, :conference_id, event_info_attributes: [:subtitle, :link, :slug, :description, :persons_raw, :tags_raw, :date, :event_id]]
    end
  end

end
