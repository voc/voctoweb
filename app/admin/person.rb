ActiveAdmin.register Person do
  menu priority: 4
  reorderable
  filter :name
  filter :email
  filter :uuid
  filter :person_identifiers_guid, as: :string, label: 'GUID'

  index do
    selectable_column
    column :name
    column :events do |person|
      person.events.count
    end
    column :created_at do |person|
      l(person.created_at, format: :pretty_datetime)
    end
    actions
  end

  show do |p|
    attributes_table do
      row :uuid
      row :name
      row :email
      row :avatar_url
    end

    panel 'Identifiers' do
      reorderable_table_for p.person_identifiers do
        column :guid
        column :source
        column :origin
        column '' do |pi|
          link_to 'Delete', [:admin, pi], method: :delete, data: { confirm: 'Remove this identifier?' }
        end
      end

      active_admin_form_for PersonIdentifier.new(person_id: p.id), url: admin_person_identifiers_path do |f|
        f.inputs do
          f.input :person_id, as: :hidden
          f.input :guid
          f.input :source, hint: 'e.g. pretalx.c3voc.de, frab.cccv.de'
          f.input :origin
        end
        f.actions
      end
    end

    panel 'Links' do
      reorderable_table_for p.links do
        column :link_type
        column :name
        column :url do |link|
          link_to link.url, link.url, target: '_blank', rel: 'noopener'
        end
        column :service
        column '' do |link|
          link_to 'Delete', [:admin, link], method: :delete, data: { confirm: 'Remove this link?' }
        end
      end

      active_admin_form_for Link.new(linkable_type: 'Person', linkable_id: p.id), url: admin_links_path do |f|
        f.inputs do
          f.input :linkable_type, as: :hidden
          f.input :linkable_id, as: :hidden
          f.input :url
          f.input :name
          f.input :link_type, as: :select, collection: Link::ALL_TYPES, include_blank: '— auto-detect —'
          f.input :service,   as: :select, collection: Link::SERVICES,  include_blank: '— auto-detect —'
        end
        f.actions
      end
    end

    table_for p.participations.includes(:event).order('events.date DESC') do
      column :role
      column 'Event' do |e|
        link_to e.event.title, [:admin, e.event]
        link_to e.event.conference.acronym, [:admin, e.event.conference]
      end
    end
  end

  form do |f|
    f.inputs 'Person Details' do
      f.input :name
      f.input :public_name
      f.input :email
      f.input :avatar_url
      f.input :description, as: :text, input_html: { rows: 5 }
    end

    f.inputs 'Identifiers' do
      f.has_many :person_identifiers, allow_destroy: true, new_record: 'Add identifier' do |pi|
        pi.input :guid
        pi.input :source, hint: 'e.g. pretalx, frab, penta'
        pi.input :origin
      end
    end

    f.inputs 'Links' do
      f.has_many :links, allow_destroy: true, new_record: 'Add link' do |li|
        li.input :url
        li.input :name
        li.input :link_type, as: :select, collection: Link::ALL_TYPES, include_blank: '— auto-detect —'
        li.input :service,   as: :select, collection: Link::SERVICES,  include_blank: '— auto-detect —'
      end
    end

    f.actions
  end

  # GET /admin/people/:id/merge — select merge target
  member_action :merge, method: :get do
    @person = Person.find_by_param!(params[:id])
    @candidates = Person.where.not(id: @person.id).order(:name)
  end

  # POST /admin/people/:id/merge — perform the merge
  member_action :do_merge, method: :post do
    @person = Person.find_by_param!(params[:id])
    target = Person.find(params[:target_person_id])
    @person.merge_into!(target)
    redirect_to admin_person_path(target), notice: "Merged " #{@person.name}" into "#{target.name}"."
  rescue ArgumentError => e
    redirect_to merge_admin_person_path(@person), alert: e.message
  end

  action_item :merge, only: :show do
    link_to 'Merge into…', merge_admin_person_path(person)
  end

  controller do
    def find_resource
      Person.find_by_param!(params[:id])
    end

    def permitted_params
      params.permit person: [
        :name, :public_name, :email, :avatar_url, :description,
        {
          links_attributes: [:id, :url, :name, :link_type, :service, :_destroy],
          person_identifiers_attributes: [:id, :guid, :source, :origin, :_destroy]
        }
      ]
    end
  end
end
