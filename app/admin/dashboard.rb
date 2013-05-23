ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do
        panel "Recent Conferences" do
          ul do
            Conference.recent(5).map do |conference|
              li link_to(conference.acronym, admin_conference_path(conference))
            end
          end
        end
      end
    end # columns

  end # content
end
