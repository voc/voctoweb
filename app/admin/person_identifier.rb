ActiveAdmin.register PersonIdentifier do
  menu false
  reorderable

  filter :person
  filter :guid
  filter :origin
  filter :source

  form do |f|
    f.inputs do
      f.input :person
      f.input :guid
      f.input :source, hint: 'if we know the string behind this guid, add it here, e.g. acct:user@domain.tld'
      f.input :origin, hint: 'system which generated this guid e.g. pretalx.c3voc.de, frab.cccv.de, etc.'
    end
    f.actions
  end

  controller do
    def create
      create! do |success, failure|
        success.html { redirect_to admin_person_path(resource.person) }
        failure.html { redirect_to admin_person_path(params[:person_identifier][:person_id]), alert: resource.errors.full_messages.to_sentence }
      end
    end

    def permitted_params
      params.permit person_identifier: [:person_id, :guid, :source, :origin]
    end
  end
end
