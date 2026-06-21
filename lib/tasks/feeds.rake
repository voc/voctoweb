namespace :voctoweb do
  namespace :feeds do
    desc 'Regenerate folder feeds for all conferences'
    task regenerate_folders: :environment do
      Conference.find_each do |conference|
        Feed::FolderWorker.perform_async(conference.id)
        puts "Queued folder feeds for #{conference.acronym}"
      end
    end
  end
end
