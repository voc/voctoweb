class EventUpdateWorker
  include Sidekiq::Worker
  include FahrplanParser

  # bulk update several events using the saved schedule.xml files
  def perform(ids)
    logger.info "bulk updating events from XML for events: #{ids.join(', ')}"
    @fahrplans = {}
    @event_infos = {}

    ActiveRecord::Base.transaction do
      Event.where(id: ids).each do |event|
        conference = event.conference

        fahrplan = fahrplan_for_conference(conference)
        next unless fahrplan
        info = event_info(fahrplan, event.guid)
        next unless info.present?
        event.update_event_info(info)
      end
    end
  end

  private

  def fahrplan_for_conference(conference)
    @fahrplans[conference.acronym] ||= FahrplanParser.new(conference.schedule_xml)
  end

  def event_info(fahrplan, guid)
    @event_infos[fahrplan] ||= fahrplan.event_info_by_guid
    @event_infos[fahrplan][guid]
  end
end
