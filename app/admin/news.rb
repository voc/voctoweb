ActiveAdmin.register News do
    menu :parent => "Misc"

  index do
    column :date
    column :title
    column :body
    column :updated_at
    column :created_at
    actions
  end

  form do |f|
    f.inputs "News Details" do
      f.input :date
      f.input :title
      f.input :body #, input_html: { class: 'tinymce' }
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit news: [:date, :title, :body]
    end
  end
end
