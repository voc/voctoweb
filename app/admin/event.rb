ActiveAdmin.register Event do
  filter :guid
  filter :title
  filter :link
  filter :conference, collection: proc { Conference.order(:acronym) }
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
    column :timeline_filename do |event|
      line_break_filename event.timeline_filename
    end
    column :thumbnails_filename do |event|
      line_break_filename event.thumbnails_filename
    end
    column :original_language
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
      row :timeline_filename do
        div show_event_folder e, :timeline_filename
      end
      row :thumbnails_filename do
        div show_event_folder e, :thumbnails_filename
      end
      row :conference
      row :original_language
      row :promoted
      row :subtitle
      row :link
      row :slug
      row :description
      row :persons
      row :tags
      row :date
      row :release_date
      row :metadata
    end
    table_for e.recordings.video.order('filename ASC') do
      column 'Video recordings' do |recording|
        link_to recording.filename, [:admin, recording]
      end
      column 'folder', &:folder
      column 'html5', &:html5
      column 'language', &:language
    end
    table_for e.recordings.audio.order('filename ASC') do
      column 'Audio recordings' do |recording|
        link_to recording.filename, [:admin, recording]
      end
      column 'folder', &:folder
      column 'language', &:language
    end
    table_for e.recordings.subtitle.order('filename ASC') do
      column 'Subtitle tracks' do |recording|
        link_to recording.filename, [:admin, recording]
      end
      column 'folder', &:folder
      column 'language', &:language
    end
    table_for e.recordings.slides.order('filename ASC') do
      column 'Slides' do |recording|
        link_to recording.filename, [:admin, recording]
      end
      column 'folder', &:folder
      column 'language', &:language
    end
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :guid
      f.input :conference, collection: Conference.order(:acronym)
      f.input :title
      f.input :subtitle
      f.input :description, input_html: { class: 'tinymce' }
      f.input :link
      f.input :promoted
      f.input :original_language, hint: 'ISO-639-2 codes', collection: Languages.all
      f.input :persons_raw, as: :text
      f.input :tags_raw, as: :text
      f.input :date, hint: 'Actual date of the event'
      f.input :release_date, hint: 'Release date for the video recordings'
    end
    f.inputs 'Files' do
      f.input :slug
      f.input :thumb_filename, hint: event.try(:conference).try(:get_images_path)
      f.input :poster_filename, hint: event.try(:conference).try(:get_images_path)
      f.input :timeline_filename, hint: event.try(:conference).try(:get_images_path)
      f.input :thumbnails_filename, hint: event.try(:conference).try(:get_images_path)
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
    link_to 'Add Recording', new_admin_recording_path(recording: { event_id: event.id }), method: :get
  end

  action_item(:update_promoted) do
    link_to 'Update promoted', update_promoted_from_view_count_admin_events_path, method: :post
  end

  batch_action :update_event_infos do |selection|
    EventUpdateWorker.perform_async(selection)
    redirect_to :action => :index
  end

  controller do
    def permitted_params
      params.permit event: [:guid, :thumb_filename, :poster_filename, :timeline_filename, :thumbnails_filename,
                            :conference_id, :promoted, :title, :subtitle, :link, :slug,
                            :original_language,
                            :description, :persons_raw, :tags_raw, :date, :release_date, :event_id]
    end
  end
end
