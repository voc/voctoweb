namespace :voctoweb do
  namespace :streaming do
    desc 'Update conferences streaming settings'
    task :update, [:include_private] => [:environment] do |t, args|
      ConferenceStreamingDownloadWorker.new.perform
    end
  end
end
