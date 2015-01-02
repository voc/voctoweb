module FahrplanUpdater
  extend ActiveSupport::Concern
  include FahrplanParser

  def fill_event_info
    if self.conference.downloaded?
      fahrplan = FahrplanParser.new(self.conference.schedule_xml)
      info = fahrplan.event_info_by_guid[self.guid]
      return if info.empty?
      update_event_info(info)
    end
  end

  # update event attributes from schedule XML
  def update_event_info(info)
    self.title = info.delete(:title)
    id = info.delete(:id)
    self.link = self.conference.get_event_url(id)
    self.update_attributes info
  end

  module ClassMethods
    include FahrplanParser

    # bulk update several events using the saved schedule.xml files
    def bulk_update_events(selection)
      Rails.logger.info "Bulk updating events from XML"
      fahrplans = {}
      ActiveRecord::Base.transaction do
        Event.where(id: selection).each do |event|
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
end
