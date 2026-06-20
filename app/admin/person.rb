ActiveAdmin.register Person do
  filter :name
  filter :public_name
  filter :email
  filter :person_identifiers_guid, as: :string, label: 'GUID'

  index do
    selectable_column
    column :name
    column :public_name
    column :email
    column 'GUIDs' do |person|
      person.person_identifiers.count
    end
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
      row :name
      row :public_name
      row :email
      row :avatar_url
      row :description
    end

    panel 'Links' do
      table_for p.links.order(:link_type, :name) do
        column(:url) { |l| link_to l.url, l.url, target: '_blank' }
        column :name
        column :link_type
        column :service
        column '' do |l|
          link_to 'Delete', [:admin, l], method: :delete, data: { confirm: 'Remove this link?' }
        end
      end
      div { link_to 'Add link', new_admin_link_path(link: { linkable_type: 'Person', linkable_id: p.id }) }
    end

    panel 'Identifiers' do
      table_for p.person_identifiers.order(:source, :guid) do
        column :guid
        column :source
        column '' do |pi|
          link_to 'Delete', [:admin, pi], method: :delete, data: { confirm: 'Remove this identifier?' }
        end
      end
      div { link_to 'Add identifier', new_admin_person_identifier_path(person_identifier: { person_id: p.id }) }
    end

    panel 'Events' do
      table_for p.participants.includes(:event).order('events.date DESC') do
        column 'Event' do |participant|
          link_to participant.event.title, [:admin, participant.event]
        end
        column :role
      end
    end
  end

  form do |f|
    f.inputs 'Person Details' do
      f.input :name
      f.input :public_name
      f.input :email
      f.input :avatar_url
      f.input :description
    end

    f.inputs 'Links' do
      f.has_many :links, allow_destroy: true, new_record: 'Add link' do |pl|
        pl.input :url
        pl.input :name
        pl.input :link_type, as: :select, collection: Link::PERSON_LINK_TYPES, include_blank: '— auto-detect —'
        pl.input :service,   as: :select, collection: Link::SERVICES,          include_blank: '— auto-detect —'
      end
    end

    f.inputs 'Identifiers' do
      f.has_many :person_identifiers, allow_destroy: true, new_record: 'Add identifier' do |pi|
        pi.input :guid
        pi.input :source, hint: 'e.g. pretalx, frab, penta'
      end
    end

    f.actions
  end

  # GET /admin/people/:id/merge — select merge target
  member_action :merge, method: :get do
    @person = Person.find(params[:id])
    @candidates = Person.where.not(id: @person.id).order(:name)
  end

  # POST /admin/people/:id/merge — perform the merge
  member_action :do_merge, method: :post do
    @person = Person.find(params[:id])
    target = Person.find(params[:target_person_id])
    @person.merge_into!(target)
    redirect_to admin_person_path(target), notice: "Merged "#{@person.name}" into "#{target.name}"."
  rescue ArgumentError => e
    redirect_to merge_admin_person_path(@person), alert: e.message
  end

  action_item :merge, only: :show do
    link_to 'Merge into…', merge_admin_person_path(person)
  end

  controller do
    def permitted_params
      params.permit person: [
        :name, :public_name, :email, :avatar_url, :description,
        links_attributes: [:id, :url, :name, :link_type, :service, :_destroy],
        person_identifiers_attributes: [:id, :guid, :source, :_destroy]
      ]
    end
  end
end
