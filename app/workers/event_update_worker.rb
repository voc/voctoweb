class EventUpdateWorker
  include Sidekiq::Worker
  include FahrplanParser

  # bulk update several events using the saved schedule.xml files
  def perform(ids)
    logger.info "bulk updating events from XML for events: #{ids.join(', ')}"
    fahrplans = {}
    ActiveRecord::Base.transaction do
      Event.where(id: ids).each do |event|
        conference = event.conference
        if fahrplans[conference.acronym]
          fahrplan = fahrplans[conference.acronym]
        else
          fahrplan = FahrplanParser.new(conference.schedule_xml)
          fahrplans[conference.acronym] = fahrplan
        end

        info = fahrplan.event_info_by_guid[event.guid]
        event.update_event_info(info)
      end
    end
  end
end
