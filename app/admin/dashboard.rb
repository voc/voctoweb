ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do

        panel "Running Jobs" do
          ul do
            para Delayed::Job.all.count
          end
        end

        panel "Recent Conferences" do
          ul do
            Conference.recent(5).map do |conference|
              li link_to(conference.acronym, admin_conference_path(conference))
            end
          end
        end

        panel "API Examples" do
          para "You can use the API to register a new conference. The conference `acronym` and the URL of the `schedule.xml` are required."

          pre I18n.t("media-backend.conference-api-curl")

          para "You can add images to an event, like the animated gif thumb and the poster image. The event is identified by its `guid` and the conference `acronym`."
          pre I18n.t("media-backend.event-api-curl")

          para "Recordings are added by specifiying the parent events `guid`, an URL and a `filename`."
          pre I18n.t("media-backend.recording-api-curl")

          para "Run webgen after uploads are finished."
          pre I18n.t("media-backend.webgen-api-curl")
        end
      end
    end # columns

  end # content
end
