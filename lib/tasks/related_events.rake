namespace :voctoweb do
  namespace :related do
    desc 'Update related metadata on events from recording views'
    task update: :environment do
      UpdateRelatedEvents.new.update
    end

    desc 'Clean up related'
    task clean: :environment do
      UpdateRelatedEvents.new.clean
    end

    desc 'Remove related info from all events'
    task remove: :environment do
      Event.all.map { |e|
        metadata = e.metadata
        metadata = {} unless metadata.is_a?(Hash)
        metadata.delete('related')
        e.update_columns(metadata: metadata)
      }
    end
  end
end

