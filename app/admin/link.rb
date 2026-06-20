ActiveAdmin.register Link do
  menu false

  form do |f|
    f.inputs do
      f.input :linkable_type, as: :hidden
      f.input :linkable_id,   as: :hidden
      f.input :url
      f.input :name
      f.input :link_type, as: :select, collection: Link::ALL_TYPES, include_blank: '— auto-detect —'
      f.input :service,   as: :select, collection: Link::SERVICES,  include_blank: '— auto-detect —'
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit link: [:linkable_type, :linkable_id, :url, :name, :link_type, :service]
    end
  end
end
