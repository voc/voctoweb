ActiveAdmin.register_page "Dashboard" do
  require 'sidekiq/api'
  queue = Sidekiq::Queue.new('default')

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    columns do
      column do

        panel "Running Jobs" do
          table_for queue.to_a.each do |job|
            column(:klass) { |job| status_tag(job.klass) }
            column(:id) { |job| status_tag(job.jid) }
            column(:args) { |job| status_tag(job.args) }
            column(:created_at) { |job| job.enqueued_at.to_s }
          end

          ul do
            para "total job count: " + queue.count.to_s
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
