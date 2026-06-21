ActiveAdmin.register PersonIdentifier do
  menu false

  filter :person
  filter :guid
  filter :origin
  filter :source

  form do |f|
    f.inputs do
      f.input :person
      f.input :order, as: :number
      f.input :guid
      f.input :source, hint: 'if we know the string behind this guid, add it here, e.g. acct:user@domain.tld'
      f.input :origin, hint: 'system which generated this guid e.g. pretalx.c3voc.de, frab.cccv.de, etc.'
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit person_identifier: [:person_id, :order, :guid, :source, :origin]
    end
  end
end
