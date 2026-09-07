ActiveAdmin.register Event do
  menu priority: 3
  reorderable
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
    column :conference
    column :title
    column :persons_raw
    #column :thumb_filename do |event|
    #  line_break_filename event.thumb_filename
    #end
    #column :poster_filename do |event|
    #  line_break_filename event.poster_filename
    #end
    #column :timeline_filename do |event|
    #  line_break_filename event.timeline_filename
    #end
    #column :thumbnails_filename do |event|
    #  line_break_filename event.thumbnails_filename
    #end
    #column :original_language
    column :created_at do |event|
      l(event.created_at, format: :pretty_datetime)
    end
    column :promoted
    actions
  end

  show do |e|
    attributes_table do
      row :guid
      row :conference
      row :slug do
        link_to e.slug, event_path(slug: e.slug)
      end
      row :title
      row :subtitle
      row :original_language
      row :promoted
      row :link
      row :description
      row :tags_raw
      row :date
      row :release_date
      row :doi do
        link_to e.doi, e.doi_url unless e.doi.nil?
      end
      row :notes
      row :persons do
        e.persons_raw
      end
    end

    table_for e.participations.includes(:person), as: 'Participants' do
      column :role
      column 'Person' do |p|
        link_to p.person.name, [:admin, p.person]
      end
      column :url
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

    attributes_table as: 'Images & Metadata' do
      row :metadata

      row :thumb_filename do
        div show_event_folder e, :thumb_filename unless e.thumb_filename.nil?
      end
      row :poster_filename do
        div show_event_folder e, :poster_filename unless e.poster_filename.nil?
      end
      row :timeline_filename do
        div show_event_folder e, :timeline_filename unless e.timeline_filename.nil?
      end
      row :thumbnails_filename do
        div show_event_folder e, :thumbnails_filename unless e.thumbnails_filename.nil?
      end
    end
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :guid
      f.input :slug
      f.input :conference, collection: Conference.order(:acronym)
      f.input :title
      f.input :subtitle
      f.input :description #, input_html: { class: 'tinymce' }
      f.input :original_language, hint: 'ISO-639-2 codes', collection: Languages.all
      f.input :link
    end
    f.inputs 'Participants' do
      f.input :persons_raw, as: :text,
              input_html: { rows: [f.object.persons_raw.to_s.lines.count, 3].max },
              hint: 'Legacy field — we are in the process of moving to the structured participants below'
      f.has_many :participations, allow_destroy: true, new_record: 'Add participant' do |pf|
        pf.input :role, as: :select, collection: Participation.roles.keys, include_blank: false
        pf.input :person, collection: Person.order(:name), include_blank: 'Select person'
        pf.input :order, as: :hidden
      end
    end
    f.inputs 'Meta' do
      f.input :tags_raw, as: :text, input_html: { rows: [f.object.tags_raw.to_s.lines.count, 3].max }
      f.input :date, hint: 'Actual date of the event'
      f.input :release_date, hint: 'Release date for the video recordings'
      f.input :doi, hint: 'Digital Object Identifier (DOI) e.g. 10.5446/19566 – prefixes are stripped automatically'
      f.input :notes, hint: 'Notes to be shown as a notice on the event page'
      f.input :promoted
      f.input :promotion_disabled, :as => :boolean, label: 'Disable promotion', hint: 'blacklist event, so it does not get promoted to the start page'
    end
    f.inputs 'Images' do
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
                            :conference_id, :title, :subtitle, :link, :slug,
                            :original_language, :doi, :notes, :promoted, :promotion_disabled,
                            :description, :persons_raw, :tags_raw, :date, :release_date, :event_id,
                            {
                              participations_attributes: [:id, :person_id, :role, :url, :order, :_destroy]
                            }]
    end
  end
end
