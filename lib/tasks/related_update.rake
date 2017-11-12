namespace :voctoweb do
  namespace :related do
    desc 'Update related metadata on events from recording views'
    task update: :environment do
      UpdateRelatedEvents.new.update
    end
  end
end

