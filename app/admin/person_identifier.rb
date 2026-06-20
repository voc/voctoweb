ActiveAdmin.register PersonIdentifier do
  menu false

  filter :guid
  filter :source
  filter :person

  form do |f|
    f.inputs do
      f.input :person
      f.input :guid
      f.input :source, hint: 'e.g. pretalx.c3voc.de, frab.cccv.de, etc.'
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit person_identifier: [:person_id, :guid, :source]
    end
  end
end
