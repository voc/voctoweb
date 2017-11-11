namespace :voctoweb do
  namespace :streaming do
    desc 'Update conferences streaming settings'
    task update: :environment do
      ConferenceStreamingDownloadWorker.new.perform
    end
  end
end
