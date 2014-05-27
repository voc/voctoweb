ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do

        panel "Running Jobs" do
          table_for Delayed::Job.order("created_at desc").each do |job|
            column(:resource) {|job| 
              status_tag(job_object(job))
            }
            column(:method) {|job| 
              status_tag(job_method(job))
            }
            column(:created_at) {|job| job.created_at.to_s }
            column(:run_at) {|job| job.run_at.to_s }
            column(:last_error) {|job| 
              div class: "scrollable_error" do 
                simple_format(job.last_error.to_s.truncate(1500)).html_safe
              end
            }
            column(:attempts) {|job| job.attempts.to_s }
          end

          ul do
            para "total job count: " + Delayed::Job.all.count.to_s
          end
        end

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
