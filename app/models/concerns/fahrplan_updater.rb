module FahrplanUpdater
  extend ActiveSupport::Concern
  include FahrplanParser

  def fill_event_info
    if conference.downloaded?
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

end
