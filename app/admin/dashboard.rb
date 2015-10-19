ActiveAdmin.register_page 'Dashboard' do
  require 'sidekiq/api'

  menu :priority => 1, :label => proc { I18n.t('active_admin.dashboard') }

  content :title => proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        queue = Sidekiq::Queue.new('default')
        panel 'Queued Jobs' do
          table_for queue.to_a[0..20].each do |_job|
            column(:klass) { |job| status_tag(job.klass) }
            column(:args) { |job| status_tag(job.args) }
            column(:created_at) { |job| job.enqueued_at.strftime('%H:%M:%S') }
          end

          stats = Sidekiq::Stats.new
          columns do
            column { 'queued job count: ' + queue.count.to_s }
            column { 'processed jobs:' + stats.processed.to_s }
            column { 'failed jobs:' + stats.failed.to_s }
          end
        end

        workers = Sidekiq::Workers.new
        panel 'Workers' do
          table_for workers.to_a.each do |_pid, _tid, _work|
            column(:klass) { |_pid, _tid, work| status_tag(work['payload']['class']) }
            column(:args) { |_pid, _tid, work| status_tag(work['payload']['args']) }
            column(:error_message) { |_pid, _tid, work| work['payload']['error_message'].to_s }
            column(:created_at) { |_pid, _tid, work| Time.at(work['run_at']).strftime('%H:%M:%S') }
          end

          ul do
            para 'total worker count: ' + workers.size.to_s
          end
        end

        panel 'Recent Conferences' do
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
