module FahrplanUpdater
  extend ActiveSupport::Concern
  include FahrplanParser

  def fill_event_info
    return unless conference.downloaded?
    fahrplan = FahrplanParser.new(conference.schedule_xml)
    info = fahrplan.event_info_by_guid[guid]
    return if info.empty?
    update_event_info(info)
  end

  # update event attributes from schedule XML
  def update_event_info(info)
    self.title = info.delete(:title)
    id = info.delete(:id)
    self.metadata[:remote_id] = id
    # fallback to link schedule url based link generation, when not set in fahrplan
    if info.key?('link')
      info.delete(:link)
      self.link = get_event_url(id)
    end
    update info
  end

  private

  def get_event_url(id)
    return unless conference.schedule_url.present?
    conference.schedule_url.sub('schedule.xml', "events/#{id}.html").freeze
  end
end
