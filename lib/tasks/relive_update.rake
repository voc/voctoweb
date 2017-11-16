namespace :voctoweb do
  namespace :relive do
    desc 'Update conferences relive data'
    task update: :environment do
      ConferenceReliveDownloadWorker.new.perform
    end
  end
end
