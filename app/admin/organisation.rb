ActiveAdmin.register Organisation do
  filter :name
  filter :wikidata_id
  filter :inception_date

  index do
    selectable_column
    column :name
    column :url
    column :wikidata_id
    column :inception_date
    column :updated_at
    actions
  end

  show do |o|
    attributes_table do
      row :name
      row :url
      row :wikidata_id
      row :inception_date
      row :description
      row :created_at
      row :updated_at
    end
    panel 'Conferences' do
      table_for o.conferences.order(:acronym) do
        column(:acronym) { |c| link_to c.acronym, [:admin, c] }
        column :title
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :url
      f.input :wikidata_id, hint: 'Wikidata item ID (e.g. Q12345)'
      f.input :inception_date, as: :datepicker
      f.input :description
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit organisation: %i[name url wikidata_id inception_date description]
    end
  end
end
