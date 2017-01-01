# Update events remote_id from existing schedule xml data
# This should only be needed once and can be deleted afterwards.
class UpdateRemoteId
  include FahrplanParser

  def initialize
    @fahrplans = {}
    @event_infos = {}
  end

  # bulk update several events remote id using the saved schedule.xml files
  def perform(ids)
    Rails.logger.info "bulk updating events remote id from XML for events: #{ids.join(', ')}"
    ActiveRecord::Base.transaction do
      Event.where(id: ids).includes(:conference).each do |event|
        conference = event.conference
        next unless conference.schedule_xml.present?

        fahrplan = fahrplan_for_conference(conference)
        next unless fahrplan
        info = event_info(fahrplan, event.guid)
        next unless info.present?

        id = info[:id]
        next unless id

        attribs = { metadata: event.metadata }
        attribs[:metadata][:remote_id] = id

        if event.tags.include?(id.to_s)
          event.tags.delete(id.to_s)
          attribs[:tags] = event.tags
        end

        event.update_columns(attribs)
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

