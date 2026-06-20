ActiveAdmin.register Person do
  filter :name
  filter :public_name
  filter :email

  index do
    selectable_column
    column :name
    column :public_name
    column :email
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
      row :links
    end
    table_for p.participants.includes(:event).order('events.date DESC') do
      column 'Event' do |participant|
        link_to participant.event.title, [:admin, participant.event]
      end
      column :role
    end
  end

  form do |f|
    f.inputs 'Person Details' do
      f.input :name
      f.input :public_name
      f.input :email
      f.input :avatar_url
      f.input :description
      f.input :links, as: :text, hint: 'One URL per line'
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit person: [:name, :public_name, :email, :avatar_url, :description, :links]
    end
  end
end
