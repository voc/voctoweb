ActiveAdmin.register ApiKey do
  menu :parent => "Misc"

  index do
    column :key
    column :description
    column :created_at
    actions
  end

  form do |f|
    f.inputs "API Key Details" do
      f.input :description
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit api_key: [:description]
    end
  end
end
